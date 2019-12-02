//
//  PokemonListRouterSpec.swift
//  PokemonChallengeTests
//
//  Created by Felipe Docil on 24/11/2019.
//  Copyright © 2019 Felipe Docil. All rights reserved.
//

@testable import PokemonChallenge
import Nimble
import Quick

class PokemonListRouterSpec: QuickSpec {
    override func spec() {
        describe("PokemonListRouterSpec") {
            it("configures the module") {
                let coordinator = MockPokemonListCoordinator()

                let mockNetworking = MockPokemonListNetworking()
                let mockDatabase = MockPokemonListDatabase()
                let mockServices = PokemonListServices(networking: mockNetworking, database: mockDatabase)

                let module = PokemonListRouter.build(from: coordinator, services: mockServices)

                let view = module as? PokemonListView
                let presenter = view?.presenter as? PokemonListPresenter
                let router = presenter?.router as? PokemonListRouter
                let interactor = presenter?.interactor as? PokemonListInteractor

                expect(view).notTo(beNil())
                expect(presenter).notTo(beNil())
                expect(presenter?.view).notTo(beNil())
                expect(router).notTo(beNil())
                expect(router?.output).notTo(beNil())
                expect(router?.viewController).notTo(beNil())
                expect(interactor).notTo(beNil())
                expect(interactor?.output).notTo(beNil())
                expect(interactor?.services).notTo(beNil())
            }
        }
    }
}

class MockPokemonListCoordinator: CoordinatorInput {
    var stubbedNavigationController: UINavigationController = UINavigationController()
    var navigationController: UINavigationController

    init() {
        navigationController = stubbedNavigationController
    }

    func buildRoot() -> UIViewController {
        fatalError("Dummy implementation")
    }

    func presentDetail(in navigationController: UINavigationController?, with identifier: String) {
        fatalError("Dummy implementation")
    }
}

class MockPokemonListNetworking: NetworkingServiceInput {
    var invokedPokemonURLs = false
    var invokedPokemonURLsCount = 0
    var invokedPokemonURLsParameters: (offset: Int, Void)?
    var invokedPokemonURLsParametersList = [(offset: Int, Void)]()
    var stubbedPokemonURLsCompletionHandlerResult: (Result<[URL], NetworkingServiceError>, Void)?

    func pokemonURLs(offset: Int, completionHandler: @escaping (Result<[URL], NetworkingServiceError>) -> Void) {
        invokedPokemonURLs = true
        invokedPokemonURLsCount += 1
        invokedPokemonURLsParameters = (offset, ())
        invokedPokemonURLsParametersList.append((offset, ()))
        if let result = stubbedPokemonURLsCompletionHandlerResult {
            completionHandler(result.0)
        }
    }

    var invokedPokemon = false
    var invokedPokemonCount = 0
    var invokedPokemonParameters: (urlPath: String, Void)?
    var invokedPokemonParametersList = [(urlPath: String, Void)]()
    var shouldReturnSuccess = false
    let queuePokemon = DispatchQueue(label: "update parameters list for pokemon", attributes: .concurrent)

    func pokemon(for urlPath: String, completionHandler: @escaping (Result<Pokemon, NetworkingServiceError>) -> Void) {
        
        queuePokemon.sync(flags: .barrier) {
            invokedPokemon = true
            invokedPokemonCount += 1
            invokedPokemonParameters = (urlPath, ())
            invokedPokemonParametersList.append((urlPath, ()))
        }
        
        if shouldReturnSuccess {
            let identifier = Int(urlPath.split(separator: "/").last!)!
            let pokemon = Pokemon.fakePokemon.first(where: { $0.identifier == identifier })
            completionHandler(.success(pokemon!))
        } else {
            completionHandler(.failure(.noNetwork))
        }
    }

    var invokedImage = false
    var invokedImageCount = 0
    var invokedImageParameters: (urlPath: String, Void)?
    var invokedImageParametersList = [(urlPath: String, Void)]()
    var stubbedImageCompletionHandlerResult: (Result<Data, NetworkingServiceError>, Void)?
    var shouldFailOnShiny = false
    let queueImage = DispatchQueue(label: "update parameters list for image", attributes: .concurrent)

    func image(for urlPath: String, completionHandler: @escaping (Result<Data, NetworkingServiceError>) -> Void) {
        
        let isShiny = urlPath.contains("shiny")
        
        queueImage.sync(flags: .barrier) {
            invokedImage = true
            invokedImageCount += 1
            invokedImageParameters = (urlPath, ())
            invokedImageParametersList.append((urlPath, ()))
        }
        
        if let result = stubbedImageCompletionHandlerResult, isShiny == false  {
            completionHandler(result.0); return
        }
        
        if let result = stubbedImageCompletionHandlerResult, shouldFailOnShiny == false && isShiny == true {
            completionHandler(result.0); return
        }
        
        completionHandler(.failure(.noNetwork))
    }
}

class MockPokemonListDatabase: DatabaseServiceInput {
    var invokedInsertPokemon = false
    var invokedInsertPokemonCount = 0
    var invokedInsertPokemonParameters: (pokemon: Pokemon, Void)?
    var invokedInsertPokemonParametersList = [(pokemon: Pokemon, Void)]()
    var stubbedInsertPokemonResult: PokemonManaged!
    let queue = DispatchQueue(label: "Update parameters", attributes: .concurrent)

    func insertPokemon(pokemon: Pokemon) -> PokemonManaged? {
        queue.sync(flags: .barrier) {
            invokedInsertPokemon = true
            invokedInsertPokemonCount += 1
            invokedInsertPokemonParameters = (pokemon, ())
            invokedInsertPokemonParametersList.append((pokemon, ()))
        }
        
        return stubbedInsertPokemonResult
    }

    var invokedFetchAllPokemon = false
    var invokedFetchAllPokemonCount = 0
    var stubbedFetchAllPokemonResult: [Pokemon]! = []

    func fetchAllPokemon() -> [Pokemon] {
        invokedFetchAllPokemon = true
        invokedFetchAllPokemonCount += 1
        return stubbedFetchAllPokemonResult
    }
}
