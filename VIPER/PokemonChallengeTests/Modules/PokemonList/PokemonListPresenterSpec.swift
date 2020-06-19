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

                self.mockInteractor.stubbedPokemonCompletionHandlerResult = (.success(pokemonList), ())
                self.mockInteractor.stubbedImagesCompletionHandlerResult = (.success(pokemonWithImage), ())

                self.presenter.viewIsReady()

                expect(self.mockView.invokedSetupInitialState) == true
                expect(self.mockInteractor.invokedPokemon) == true
                expect(self.presenter.dataSource.count).toEventually(equal(10))
                expect(self.mockView.invokedReloadList).toEventually(beTrue())
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

            self.mockInteractor.stubbedPokemonCompletionHandlerResult = (.success(pokemonList), ())
            self.mockInteractor.stubbedImagesCompletionHandlerResult = (.success(pokemonWithImage), ())

            self.presenter.loadNewPokemon()

            expect(self.mockInteractor.invokedPokemon) == true
            expect(self.presenter.dataSource.count).toEventually(equal(10))
            expect(self.mockView.invokedReloadList).toEventually(beTrue())
        }

        it("receives did select") {
            self.presenter.dataSource = Pokemon.fakePokemon

            self.presenter.didSelected(row: 0, switchSelected: false)
            expect(self.mockRouter.invokedPresentDetail) == true
            expect(self.mockRouter.invokedPresentDetailParameters?.identifier) == 1
            expect(self.mockRouter.invokedPresentDetailParameters?.isShiny) == false
        }

        it("searches") {
            let localPokemon = Pokemon.fakePokemon
            self.presenter.dataSource = localPokemon
            self.mockInteractor.stubbedLocalPokemonResult = localPokemon

            // searches for non existing term
            self.presenter.search(for: "termnotfound")

            expect(self.mockInteractor.invokedLocalPokemon) == true
            expect(self.presenter.dataSource.count) == 0
            expect(self.mockView.invokedReloadList) == true

            // cleans search field
            self.presenter.search(for: "")

            expect(self.mockInteractor.invokedLocalPokemon) == true
            expect(self.presenter.dataSource.count) == 10
            expect(self.mockView.invokedReloadList) == true

            // ignores the next pokemon list fetch when it's searching
            self.presenter.search(for: "saur")

            expect(self.mockInteractor.invokedLocalPokemon) == true
            expect(self.presenter.dataSource.count) == 3
            expect(self.mockView.invokedReloadList) == true

            self.presenter.loadNewPokemon()

            expect(self.mockInteractor.invokedPokemon) == false
        }

        it("fetches image") {
            let image = UIImage(named: "bulbasaur_default", in: Bundle(for: PokemonListPresenterSpec.self), compatibleWith: nil)!
            let pokemonList = Pokemon.fakePokemon
            var pokemonWithImage = pokemonList.first!
            pokemonWithImage.image = image.pngData()

            self.presenter.dataSource = pokemonList

            self.mockInteractor.stubbedImagesCompletionHandlerResult = (.success(pokemonWithImage), ())

            self.presenter.updateImages(for: 1)

            expect(self.mockInteractor.invokedImages) == true
            expect(self.mockView.invokedReloadList).toEventually(equal(true))
            expect(self.mockInteractor.invokedSave).toEventually(equal(true))
            expect(self.mockInteractor.invokedSaveParameters?.pokemon).toEventually(equal([pokemonWithImage]))
        }
    }
}

class MockPokemonListInteractor: PokemonListInteractorInput {
    var invokedPokemon = false
    var invokedPokemonCount = 0
    var stubbedPokemonCompletionHandlerResult: (Result<[Pokemon], PokemonListInteractorErrors>, Void)?

    func pokemon(completionHandler: @escaping (Result<[Pokemon], PokemonListInteractorErrors>) -> Void) {
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
        }
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

    var invokedLocalPokemon = false
    var invokedLocalPokemonCount = 0
    var stubbedLocalPokemonResult: [Pokemon]! = []

    func localPokemon() -> [Pokemon] {
        invokedLocalPokemon = true
        invokedLocalPokemonCount += 1
        return stubbedLocalPokemonResult
    }
}

class MockPokemonListRouter: PokemonListRouterInput {
    static func build(from coordinator: CoordinatorInput, services: PokemonListServices) -> UIViewController {
        fatalError("Dummy implementation")
    }

    var invokedPresentDetail = false
    var invokedPresentDetailCount = 0
    var invokedPresentDetailParameters: (identifier: Int, isShiny: Bool, Void)?
    var invokedPresentDetailParametersList = [(identifier: Int, isShiny: Bool, Void)]()

    func presentDetail(for identifier: Int, isShiny: Bool) {
        invokedPresentDetail = true
        invokedPresentDetailCount += 1
        invokedPresentDetailParameters = (identifier, isShiny, ())
        invokedPresentDetailParametersList.append((identifier, isShiny, ()))
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
