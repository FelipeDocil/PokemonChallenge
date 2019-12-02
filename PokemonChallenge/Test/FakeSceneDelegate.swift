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
        return [
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
        return [
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
        
        // Mulitpe Page
        if arguments.contains(Arguments.Networking.multiplePages.rawValue) && offset <= 5 {
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
}

class MockDatabase: DatabaseServiceInput {
    var cache: [Pokemon] = []
    let queue = DispatchQueue(label: "update cache", attributes: .concurrent)
    
    func insertPokemon(pokemon: Pokemon) -> PokemonManaged? {
        queue.sync(flags: .barrier) {
            cache.append(pokemon)
        }
        
        return nil
    }
    
    func fetchAllPokemon() -> [Pokemon] {
        let arguments = ProcessInfo.processInfo.arguments
        
        if arguments.contains(Arguments.Persistence.caches.rawValue) { return cache }
        if arguments.contains(Arguments.Persistence.cached.rawValue) { return Array(Pokemon.fakePokemon[0..<5]) }
        if arguments.contains(Arguments.Persistence.empty.rawValue) { return [] }
        
        return []
    }
}

// Coordinator

class MockCoordinator: CoordinatorInput, CoordinatorBuilder {
    func presentDetail(in navigationController: UINavigationController?, with identifier: String) {
        fatalError()
    }
    
    lazy var networkingService: NetworkingServiceInput = MockNetworking()
    lazy var databaseService: DatabaseServiceInput = MockDatabase()
    
    func buildRoot() -> UIViewController {
        let arguments = ProcessInfo.processInfo.arguments
        var controller: UIViewController = UIViewController()
        
        if arguments.contains(Arguments.Initial.list.rawValue) { controller = buildPokemonList() }
        
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
