//
//  PokemonDetailRouterSpec.swift
//  PokemonChallengeTests
//
//  Created by Felipe Docil on 04/12/2019.
//  Copyright © 2019 Felipe Docil. All rights reserved.
//

@testable import PokemonChallenge
import Nimble
import Quick

class PokemonDetailRouterSpec: QuickSpec {
    override func spec() {
        describe("PokemonDetailRouterSpec") {
            it("configures the module") {
                let coordinator = MockPokemonDetailCoordinator()
                let mockNetworking = MockPokemonDetailNetworking()
                let mockDatabase = MockPokemonDetailDatabase()

                let mockServices = PokemonDetailServices(networking: mockNetworking, database: mockDatabase)

                let module = PokemonDetailRouter.build(from: coordinator, services: mockServices, identifier: 1, isShiny: false)

                let view = module as? PokemonDetailView
                let presenter = view?.presenter as? PokemonDetailPresenter
                let router = presenter?.router as? PokemonDetailRouter
                let interactor = presenter?.interactor as? PokemonDetailInteractor

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

class MockPokemonDetailCoordinator: CoordinatorInput {
    var stubbedNavigationController: UINavigationController = UINavigationController()
    var navigationController: UINavigationController

    init() {
        navigationController = stubbedNavigationController
    }

    func buildRoot() -> UIViewController {
        fatalError("Dummy implementation")
    }

    var invokedPresentDetail = false
    var invokedPresentDetailCount = 0
    var invokedPresentDetailParameters: (navigationController: UINavigationController?, identifier: Int, isShiny: Bool)?
    var invokedPresentDetailParametersList = [(navigationController: UINavigationController?, identifier: Int, isShiny: Bool)]()

    func presentDetail(in navigationController: UINavigationController?, with identifier: Int, isShiny: Bool) {
        invokedPresentDetail = true
        invokedPresentDetailCount += 1
        invokedPresentDetailParameters = (navigationController, identifier, isShiny)
        invokedPresentDetailParametersList.append((navigationController, identifier, isShiny))
    }
}

class MockPokemonDetailNetworking: NetworkingServiceInput {
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

    var invokedEntries = false
    var invokedEntriesCount = 0
    var invokedEntriesParameters: (urlPath: String, Void)?
    var invokedEntriesParametersList = [(urlPath: String, Void)]()
    var stubbedEntriesCompletionHandlerResult: (Result<[Entry], NetworkingServiceError>, Void)?
    func entries(for urlPath: String, completionHandler: @escaping (Result<[Entry], NetworkingServiceError>) -> Void) {
        invokedEntries = true
        invokedEntriesCount += 1
        invokedEntriesParameters = (urlPath, ())
        invokedEntriesParametersList.append((urlPath, ()))
        if let result = stubbedEntriesCompletionHandlerResult {
            completionHandler(result.0)
        }
    }
}

class MockPokemonDetailDatabase: DatabaseServiceInput {
    var invokedAllPokemon = false
    var invokedAllPokemonCount = 0
    var stubbedAllPokemonResult: [Pokemon]! = []

    func allPokemon() -> [Pokemon] {
        invokedAllPokemon = true
        invokedAllPokemonCount += 1
        return stubbedAllPokemonResult
    }

    var invokedPokemon = false
    var invokedPokemonCount = 0
    var invokedPokemonParameters: (identifier: Int, Void)?
    var invokedPokemonParametersList = [(identifier: Int, Void)]()
    var stubbedPokemonResult: Pokemon!

    func pokemon(identifier: Int) -> Pokemon? {
        invokedPokemon = true
        invokedPokemonCount += 1
        invokedPokemonParameters = (identifier, ())
        invokedPokemonParametersList.append((identifier, ()))
        return stubbedPokemonResult
    }

    var invokedSave = false
    var invokedSaveCount = 0
    var invokedSaveParameters: (pokemon: [Pokemon], Void)?
    var invokedSaveParametersList = [(pokemon: [Pokemon], Void)]()

    func save(pokemon: [Pokemon]) {
        invokedSave = true
        invokedSaveCount += 1
        invokedSaveParameters = (pokemon, ())
        invokedSaveParametersList.append((pokemon, ()))
    }

    var invokedSaveEntries = false
    var invokedSaveEntriesCount = 0
    var invokedSaveEntriesParameters: (entries: [Entry], pokemon: Pokemon)?
    var invokedSaveEntriesParametersList = [(entries: [Entry], pokemon: Pokemon)]()

    func save(entries: [Entry], to pokemon: Pokemon) {
        invokedSaveEntries = true
        invokedSaveEntriesCount += 1
        invokedSaveEntriesParameters = (entries, pokemon)
        invokedSaveEntriesParametersList.append((entries, pokemon))
    }
}
