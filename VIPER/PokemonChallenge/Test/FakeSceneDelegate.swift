//
//  FakeSceneDelegate.swift
//  PokemonChallenge
//
//  Created by Felipe Docil on 25/11/2019.
//  Copyright © 2019 Felipe Docil. All rights reserved.
//

import UIKit

// Entities

extension PokemonURL {
    static var fakeURLs: [PokemonURL] {
        [
            PokemonURL(url: URL(string: "https://pokeapi.co/api/v2/pokemon/1/")!),
            PokemonURL(url: URL(string: "https://pokeapi.co/api/v2/pokemon/2/")!),
            PokemonURL(url: URL(string: "https://pokeapi.co/api/v2/pokemon/3/")!),
            PokemonURL(url: URL(string: "https://pokeapi.co/api/v2/pokemon/4/")!),
            PokemonURL(url: URL(string: "https://pokeapi.co/api/v2/pokemon/5/")!),
            PokemonURL(url: URL(string: "https://pokeapi.co/api/v2/pokemon/6/")!),
            PokemonURL(url: URL(string: "https://pokeapi.co/api/v2/pokemon/7/")!),
            PokemonURL(url: URL(string: "https://pokeapi.co/api/v2/pokemon/8/")!),
            PokemonURL(url: URL(string: "https://pokeapi.co/api/v2/pokemon/9/")!),
            PokemonURL(url: URL(string: "https://pokeapi.co/api/v2/pokemon/10/")!),
        ]
    }

    static var fakeURLs_secondPage: [PokemonURL] {
        [
            PokemonURL(url: URL(string: "https://pokeapi.co/api/v2/pokemon/11/")!),
            PokemonURL(url: URL(string: "https://pokeapi.co/api/v2/pokemon/12/")!),
            PokemonURL(url: URL(string: "https://pokeapi.co/api/v2/pokemon/13/")!),
            PokemonURL(url: URL(string: "https://pokeapi.co/api/v2/pokemon/14/")!),
            PokemonURL(url: URL(string: "https://pokeapi.co/api/v2/pokemon/15/")!),
        ]
    }
}

extension Pokemon {
    static var fakePokemon: [Pokemon] {
        guard let path = Bundle.main.path(forResource: "fake_pokemon", ofType: "json") else { return [] }
        let url = URL(fileURLWithPath: path)

        guard let data = try? Data(contentsOf: url, options: .mappedIfSafe) else { return [] }

        let decoder = JSONDecoder()
        let pokemon = try? decoder.decode([Pokemon].self, from: data)

        return pokemon ?? []
    }

    static var fakePokemon_secondPage: [Pokemon] {
        guard let path = Bundle.main.path(forResource: "fake_pokemon_10", ofType: "json") else { return [] }
        let url = URL(fileURLWithPath: path)

        guard let data = try? Data(contentsOf: url, options: .mappedIfSafe) else { return [] }

        let decoder = JSONDecoder()
        let pokemon = try? decoder.decode([Pokemon].self, from: data)

        return pokemon ?? []
    }
}

extension Entry {
    static var fakeEntries: [Entry] {
        guard let path = Bundle.main.path(forResource: "fake_entries", ofType: "json") else { return [] }
        let url = URL(fileURLWithPath: path)

        guard let data = try? Data(contentsOf: url, options: .mappedIfSafe) else { return [] }

        let decoder = JSONDecoder()
        let entries = try? decoder.decode([Entry].self, from: data)

        return entries ?? []
    }
}

// Services

class MockNetworking: NetworkingServiceInput {
    func image(for urlPath: String, completionHandler: @escaping (Result<Data, NetworkingServiceError>) -> Void) {
        guard let last = urlPath.split(separator: "/").last else { completionHandler(.failure(.noNetwork)); return }

        let identifier = last.replacingOccurrences(of: ".png", with: "")
        let isShiny = urlPath.contains("shiny")
        let imageName = "\(identifier)_\(isShiny ? "shiny" : "default")"

        guard let image = UIImage(named: imageName, in: Bundle(for: MockNetworking.self), compatibleWith: nil) else { completionHandler(.failure(.noNetwork)); return }

        completionHandler(.success(image.pngData()!))
    }

    func pokemonURLs(offset: Int, completionHandler: @escaping (Result<[URL], NetworkingServiceError>) -> Void) {
        let arguments = ProcessInfo.processInfo.arguments

        // No network
        if arguments.contains(Arguments.Networking.noNetwork.rawValue) { completionHandler(.failure(.noNetwork)); return }

        // Single Page
        if arguments.contains(Arguments.Networking.singlePage.rawValue) && offset <= 5 { completionHandler(.success(PokemonURL.fakeURLs.compactMap { $0.url } )); return }
        else if arguments.contains(Arguments.Networking.singlePage.rawValue) {
        completionHandler(.success([])); return }

        // Multiple Page
        if arguments.contains(Arguments.Networking.multiplePages.rawValue) && offset == 0 {
        completionHandler(.success(PokemonURL.fakeURLs.compactMap { $0.url } )); return }
        else if arguments.contains(Arguments.Networking.multiplePages.rawValue) && offset == 10 {
            completionHandler(.success(PokemonURL.fakeURLs_secondPage.compactMap { $0.url } )); return }
        else if arguments.contains(Arguments.Networking.multiplePages.rawValue) {
            completionHandler(.success([])); return }

        // Fallback
        completionHandler(.failure(.noNetwork))
    }

    func pokemon(for urlPath: String, completionHandler: @escaping (Result<Pokemon, NetworkingServiceError>) -> Void) {
        let arguments = ProcessInfo.processInfo.arguments

        if arguments.contains(Arguments.Networking.noNetwork.rawValue) { completionHandler(.failure(.noNetwork)); return }
        if arguments.contains(Arguments.Networking.successPokemon.rawValue) {
            let identifier = Int(urlPath.split(separator: "/").last!)!
            if let pokemon_firstPage = Pokemon.fakePokemon.first(where: { $0.identifier == identifier }) {
                completionHandler(.success(pokemon_firstPage)); return
            }

            let pokemon_secondPage = Pokemon.fakePokemon_secondPage.first(where: { $0.identifier == identifier })
            completionHandler(.success(pokemon_secondPage!)); return
        }

        completionHandler(.failure(.noNetwork))
    }

    func entries(for urlPath: String, completionHandler: @escaping (Result<[Entry], NetworkingServiceError>) -> Void) {
        let arguments = ProcessInfo.processInfo.arguments

        if arguments.contains(Arguments.Networking.noNetwork.rawValue) { completionHandler(.failure(.noNetwork)); return }

        if arguments.contains(Arguments.Networking.successEntry.rawValue) {
            completionHandler(.success(Entry.fakeEntries))
        }

         completionHandler(.failure(.noNetwork))
    }
}

class MockDatabase: DatabaseServiceInput {
    lazy var cache: [Pokemon] = {
        let arguments = ProcessInfo.processInfo.arguments

        if arguments.contains(Arguments.Persistence.initialPokemon.rawValue) {
            return Array(Pokemon.fakePokemon[0..<5])
        }

        return []
    }()
    let queue = DispatchQueue(label: "update cache", attributes: .concurrent)

    func save(pokemon: [Pokemon]) {
        queue.sync(flags: .barrier) {
            cache.append(contentsOf: pokemon)
        }
    }

    func allPokemon() -> [Pokemon] {
        var filtered: [Pokemon] = []

        for element in cache {
            let existing = filtered.filter { element.identifier == $0.identifier }
            if existing.isEmpty { filtered.append(element) }
        }

        return filtered.sorted { $0.identifier <= $1.identifier }
    }

    func pokemon(identifier: Int) -> Pokemon? {
        let arguments = ProcessInfo.processInfo.arguments

        if let pokemon = cache.first(where: { $0.identifier == identifier } ) {
            return pokemon
        }

        let image = UIImage(named: "1_default", in: Bundle(for: MockNetworking.self), compatibleWith: nil)
        let shiny = UIImage(named: "1_shiny", in: Bundle(for: MockNetworking.self), compatibleWith: nil)

        var fakePokemon = Pokemon.fakePokemon.first
        fakePokemon?.image = image?.pngData()
        fakePokemon?.shiny = shiny?.pngData()

        if arguments.contains(Arguments.Persistence.initialEntry.rawValue) {
            let entry = Entry.fakeEntries.filter { entry -> Bool in
                entry.language.lowercased() == "en"
            }
            fakePokemon?.entry = entry
        }

        return fakePokemon
    }

    func save(entries: [Entry], to pokemon: Pokemon) {

    }
}

// Coordinator

class MockCoordinator: CoordinatorInput, CoordinatorBuilder {
    func presentDetail(in navigationController: UINavigationController?, with identifier: Int, isShiny: Bool) {
        let detail = buildPokemonDetail(for: identifier, isShiny: isShiny)

        DispatchQueue.main.async {
            navigationController?.pushViewController(detail, animated: true)
        }
    }

    lazy var networkingService: NetworkingServiceInput = MockNetworking()
    lazy var databaseService: DatabaseServiceInput = MockDatabase()

    func buildRoot() -> UIViewController {
        let arguments = ProcessInfo.processInfo.arguments
        var controller: UIViewController = UIViewController()

        if arguments.contains(Arguments.Initial.list.rawValue) { controller = buildPokemonList() }
        if arguments.contains(Arguments.Initial.detail.rawValue) { controller = buildPokemonDetail(for: 1, isShiny: false) }
        if arguments.contains(Arguments.Initial.detailShiny.rawValue) { controller = buildPokemonDetail(for: 1, isShiny: true) }

        let navigationController = UINavigationController(rootViewController: controller)
        return navigationController
    }
}

// SceneDelegate

class FakeSceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var coordinator: CoordinatorInput?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard
            let windowScene = (scene as? UIWindowScene)
        else { return }

        coordinator = MockCoordinator()
        let controller = coordinator?.buildRoot()

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = controller
        window.backgroundColor = .white

        self.window = window
        window.makeKeyAndVisible()
    }
}
