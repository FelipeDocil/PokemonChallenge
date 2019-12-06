// 
//  PokemonDetailInteractor.swift
//  PokemonChallenge
//
//  Created by Felipe Docil on 04/12/2019.
//  Copyright © 2019 Felipe Docil. All rights reserved.
//

import Foundation

enum PokemonDetailInteractorErrors: Error {
    case networking(Error)
    case noPokemon
}
    
protocol PokemonDetailInteractorInput: AnyObject {
    func information(for identifier: Int, isShiny: Bool) -> (image: Data?, name: String)
    func fetchEntries(for identifier: Int, completionHandler: @escaping (Result<[Entry], PokemonDetailInteractorErrors>) -> Void)
}

protocol PokemonDetailInteractorOutput: AnyObject {}

class PokemonDetailInteractor: PokemonDetailInteractorInput {
    weak var output: PokemonDetailInteractorOutput?
    var services: PokemonDetailServices?

    // MARK: PokemonDetailInteractorInput
    
    func information(for identifier: Int, isShiny: Bool) -> (image: Data?, name: String) {
        let pokemon = services?.database.pokemon(identifier: identifier)
        let image = isShiny == true ? pokemon?.shiny : pokemon?.image
        
        return (image: image, name: pokemon?.name ?? "")
    }
    
    func fetchEntries(for identifier: Int, completionHandler: @escaping (Result<[Entry], PokemonDetailInteractorErrors>) -> Void) {
        guard let pokemon = services?.database.pokemon(identifier: identifier) else {
            completionHandler(.failure(.noPokemon)); return
        }
        
        services?.networking.entries(for: pokemon.pokedexPath.absoluteString) { result in
            switch result {
            case let .failure(error): completionHandler(.failure(.networking(error)))
            case let .success(entries): completionHandler(.success(entries))
            }
        }
    }
}
