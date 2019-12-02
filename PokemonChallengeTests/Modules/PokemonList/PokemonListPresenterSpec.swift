//
//  PokemonListPresenterSpec.swift
//  PokemonChallengeTests
//
//  Created by Felipe Docil on 24/11/2019.
//  Copyright © 2019 Felipe Docil. All rights reserved.
//

@testable import PokemonChallenge
import Nimble
import Quick

class PokemonListPresenterSpec: QuickSpec {
    var mockView: MockPokemonListView!
    var mockRouter: MockPokemonListRouter!
    var mockInteractor: MockPokemonListInteractor!
    var presenter: PokemonListPresenter!
    
    override func spec() {
        beforeEach {
            self.mockView = MockPokemonListView()
            self.mockRouter = MockPokemonListRouter()
            self.mockInteractor = MockPokemonListInteractor()
            
            self.presenter = PokemonListPresenter(interactor: self.mockInteractor, router: self.mockRouter)
            self.presenter.view = self.mockView
        }
        describe("PokemonListPresenterSpec") {
            it("configures view") {
                let image = UIImage(named: "bulbasaur_default", in: Bundle(for: PokemonListPresenterSpec.self), compatibleWith: nil)!
                let pokemonList = Pokemon.fakePokemon
                var pokemonWithImage = pokemonList.first!
                pokemonWithImage.image = image.pngData()
                var pokemonListWithImage = pokemonList
                pokemonListWithImage[0] = pokemonWithImage

                self.mockInteractor.stubbedPokemonCompletionHandlerResult = (.success(Set(pokemonList)), ())
                self.mockInteractor.stubbedImagesCompletionHandlerResult = (.success(pokemonWithImage), ())

                self.presenter.viewIsReady()

                expect(self.mockView.invokedSetupInitialState) == true
                expect(self.mockInteractor.invokedPokemon) == true

                expect(self.mockInteractor.invokedImagesCount).toEventually(equal(pokemonList.count))
                expect(self.presenter.dataSource.count).toEventually(equal(10))
                expect(self.presenter.dataSource.first?.image).toNotEventually(beNil())
                expect(self.mockView.invokedReloadList).toEventually(beTrue())
                expect(self.mockInteractor.invokedSave).toEventually(beTrue())
                expect(self.mockInteractor.invokedSaveParameters?.pokemon).toEventually(equal(pokemonListWithImage))
            }
        }
        
        it("returns the number of itens on the datasource") {
            self.presenter.dataSource = Pokemon.fakePokemon

            let count = self.presenter.numberOfItems()
            expect(count) == 10
        }
        
        it("returns card information for first item") {
            self.presenter.dataSource = Pokemon.fakePokemon

            let information = self.presenter.cardInformation(for: 0)

            expect(information.image).to(beNil())
            expect(information.shiny).to(beNil())
            expect(information.name) == "bulbasaur"
            expect(information.identifier) == 1
        }
        
        it("receives reach end of page") {
            let image = UIImage(named: "bulbasaur_default", in: Bundle(for: PokemonListPresenterSpec.self), compatibleWith: nil)!
            let pokemonList = Pokemon.fakePokemon
            var pokemonWithImage = pokemonList.first!
            pokemonWithImage.image = image.pngData()
            var pokemonListWithImage = pokemonList
            pokemonListWithImage[0] = pokemonWithImage
            
            self.mockInteractor.stubbedPokemonCompletionHandlerResult = (.success(Set(pokemonList)), ())
            self.mockInteractor.stubbedImagesCompletionHandlerResult = (.success(pokemonWithImage), ())

            self.presenter.reachEndOfPage()

            expect(self.mockInteractor.invokedPokemon) == true

            expect(self.mockInteractor.invokedImagesCount).toEventually(equal(pokemonList.count))
            expect(self.presenter.dataSource.count).toEventually(equal(10))
            expect(self.presenter.dataSource.first?.image).toNotEventually(beNil())
            expect(self.mockView.invokedReloadList).toEventually(beTrue())
            expect(self.mockInteractor.invokedSave).toEventually(beTrue())
            expect(self.mockInteractor.invokedSaveParameters?.pokemon).toEventually(equal(pokemonListWithImage))
        }
    }
}

class MockPokemonListInteractor: PokemonListInteractorInput {
    var invokedPokemon = false
    var invokedPokemonCount = 0
    var stubbedPokemonCompletionHandlerResult: (Result<Set<Pokemon>, PokemonListInteractorErrors>, Void)?

    func pokemon(completionHandler: @escaping (Result<Set<Pokemon>, PokemonListInteractorErrors>) -> Void) {
        invokedPokemon = true
        invokedPokemonCount += 1
        if let result = stubbedPokemonCompletionHandlerResult {
            completionHandler(result.0)
        }
    }

    var invokedImages = false
    var invokedImagesCount = 0
    var invokedImagesParameters: (pokemon: Pokemon, Void)?
    var invokedImagesParametersList = [(pokemon: Pokemon, Void)]()
    var stubbedImagesCompletionHandlerResult: (Result<Pokemon, PokemonListInteractorErrors>, Void)?
    let queue = DispatchQueue(label: "update parameters list", attributes: .concurrent)

    func images(for pokemon: Pokemon,
                completionHandler: @escaping (Result<Pokemon, PokemonListInteractorErrors>) -> Void) {
        
        queue.sync(flags: .barrier) {
            invokedImages = true
            invokedImagesCount += 1
            invokedImagesParameters = (pokemon, ())
            invokedImagesParametersList.append((pokemon, ()))
        }
        
        if let result = stubbedImagesCompletionHandlerResult, pokemon.identifier == 1 {
            completionHandler(result.0)
        } else {
            completionHandler(.failure(.noImage))
        }
    }
    
    var invokedSave = false
    var invokedSaveCount = 0
    var invokedSaveParameters: (pokemon: [Pokemon], Void)?
    var invokedSaveParametersList = [(pokemon: [Pokemon], Void)]()
    
    func save(pokemon: [Pokemon], completionHandler: @escaping () -> ()) {
        invokedSave = true
        invokedSaveCount += 1
        invokedSaveParameters = (pokemon, ())
        invokedSaveParametersList.append((pokemon, ()))
        
        completionHandler()
    }
}

class MockPokemonListRouter: PokemonListRouterInput {
    static func build(from coordinator: CoordinatorInput, services: PokemonListServices) -> UIViewController {
        fatalError("Dummy implementation")
    }
}

class MockPokemonListView: PokemonListViewInput {
    var invokedSetupInitialState = false
    var invokedSetupInitialStateCount = 0

    func setupInitialState() {
        invokedSetupInitialState = true
        invokedSetupInitialStateCount += 1
    }

    var invokedReloadList = false
    var invokedReloadListCount = 0

    func reloadList() {
        invokedReloadList = true
        invokedReloadListCount += 1
    }
}
