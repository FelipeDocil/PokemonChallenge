//
//  PokemonListInteractor.swift
//  PokemonChallenge
//
//  Created by Felipe Docil on 23/11/2019.
//  Copyright © 2019 Felipe Docil. All rights reserved.
//

import Foundation

enum PokemonListInteractorErrors: Error {
    case networking(Error)
    case noImage
}

extension PokemonListInteractorErrors: Equatable {
    static func == (lhs: PokemonListInteractorErrors, rhs: PokemonListInteractorErrors) -> Bool {
        switch (lhs, rhs) {
        case (.noImage, .noImage): return true
        case let (.networking(lhsError), .networking(rhsError)): return lhsError.localizedDescription == rhsError.localizedDescription
        default: return false
        }
    }
}

protocol PokemonListInteractorInput: AnyObject {
    func pokemon(completionHandler: @escaping (Result<[Pokemon], PokemonListInteractorErrors>) -> Void)
    func images(for pokemon: Pokemon, completionHandler: @escaping (Result<Pokemon, PokemonListInteractorErrors>) -> Void)
    func save(pokemon: [Pokemon])
    func localPokemon() -> [Pokemon]
}

protocol PokemonListInteractorOutput: AnyObject {}

class PokemonListInteractor: PokemonListInteractorInput {
    weak var output: PokemonListInteractorOutput?
    var services: PokemonListServices?

    // MARK: PokemonListInteractorInput
    func pokemon(completionHandler: @escaping (Result<[Pokemon], PokemonListInteractorErrors>) -> Void) {
        var localPokemon: [Pokemon] = services?.database.allPokemon() ?? []

        if localPokemon.count > 0 {
            completionHandler(.success(localPokemon))
        }

        let identifiers = localPokemon.compactMap { $0.identifier }.sorted()
        let offset = firstMissingIdentifier(list: identifiers)

        services?.networking.pokemonURLs(offset: offset - 1) { result in
            switch result {
            case let .failure(error): completionHandler(.failure(.networking(error)))
            case let .success(pokemonURLs):
                // Start to fetch pokemon
                let downloadGroup = DispatchGroup()
                let _ = DispatchQueue.global(qos: .userInitiated)

                // Send n threads to fetch pokemon
                let queue = DispatchQueue(label: "Update localPokemon", attributes: .concurrent)
                DispatchQueue.concurrentPerform(iterations: pokemonURLs.count) { index in
                    let url = pokemonURLs[index]

                    downloadGroup.enter()
                    self.services?.networking.pokemon(for: url.absoluteString) { result in
                        if case let .success(pokemon) = result {
                            queue.async(flags: .barrier) {
                                localPokemon.append(pokemon)
                            }
                        }

                        downloadGroup.leave()
                    }
                }

                downloadGroup.notify(queue: DispatchQueue.main) {
                    self.services?.database.save(pokemon: localPokemon)
                    let updatedLocal = self.services?.database.allPokemon() ?? localPokemon
                    completionHandler(.success(updatedLocal))
                }
            }
        }
    }

    func images(for pokemon: Pokemon, completionHandler: @escaping (Result<Pokemon, PokemonListInteractorErrors>) -> Void) {
        var pokemon = pokemon

        services?.networking.image(for: pokemon.imagePath.absoluteString) { result in
            switch result {
            case let .success(image):
                pokemon.image = image

                self.services?.networking.image(for: pokemon.shinyPath.absoluteString) { result in
                    switch result {
                    case let .success(shiny):
                        pokemon.shiny = shiny

                        completionHandler(.success(pokemon))

                    case .failure: completionHandler(.success(pokemon))
                    }
                }
            case .failure: completionHandler(.failure(.noImage))
            }
        }
    }

    func save(pokemon: [Pokemon]) {
        services?.database.save(pokemon: pokemon)
    }

    func localPokemon() -> [Pokemon] {
        services?.database.allPokemon() ?? []
    }

    // MARK: Private methods
    private func firstMissingIdentifier(list: [Int]) -> Int {
        findFirstMissing(list: list, start: 1, end: list.count)
    }

    private func findFirstMissing(list: [Int], start: Int, end: Int) -> Int {
        if start > end { return end + 1 }
        if start != list[start - 1] { return start }

        let mid = (start + end) / 2

        if list[mid - 1] == mid { return findFirstMissing(list: list, start: mid + 1, end: end) }

        return findFirstMissing(list: list, start: start, end: mid)
    }
}
