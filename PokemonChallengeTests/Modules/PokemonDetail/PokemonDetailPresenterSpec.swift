//
//  PokemonDetailPresenterSpec.swift
//  PokemonChallengeTests
//
//  Created by Felipe Docil on 04/12/2019.
//  Copyright © 2019 Felipe Docil. All rights reserved.
//

@testable import PokemonChallenge
import Nimble
import Quick

class PokemonDetailPresenterSpec: QuickSpec {
    override func spec() {
        describe("PokemonDetailPresenterSpec") {
            it("configures view") {
                let mockView = MockPokemonDetailView()
                let mockRouter = MockPokemonDetailRouter()
                let mockInteractor = MockPokemonDetailInteractor()
                let presenter = PokemonDetailPresenter(interactor: mockInteractor, router: mockRouter, identifier: 1, isShiny: false)
                presenter.view = mockView

                let image = UIImage(named: "bulbasaur_default", in: Bundle(for: PokemonCardSpec.self), compatibleWith: nil)!.pngData()
                let expectedViewData = PokemonDetailViewData(image: image, name: "bulbasaur", isShiny: false)
                
                mockInteractor.stubbedInformationResult = (image: image, name: "bulbasaur")

                presenter.viewIsReady()

                expect(mockView.invokedSetupInitialStateParameters?.viewData) == expectedViewData
                expect(mockInteractor.invokedInformation) == true
            }
        }
    }
}

class MockPokemonDetailInteractor: PokemonDetailInteractorInput {
    var invokedFetchEntries = false
    var invokedFetchEntriesCount = 0
    var invokedFetchEntriesParameters: (offset: Int, Void)?
    var invokedFetchEntriesParametersList = [(offset: Int, Void)]()
    var stubbedFetchEntriesCompletionHandlerResult: (Result<[Entry], PokemonDetailInteractorErrors>, Void)?

    func fetchEntries(for identifier: Int, completionHandler: @escaping (Result<[Entry], PokemonDetailInteractorErrors>) -> Void) {
        invokedFetchEntries = true
        invokedFetchEntriesCount += 1
        invokedFetchEntriesParameters = (identifier, ())
        invokedFetchEntriesParametersList.append((identifier, ()))
        if let result = stubbedFetchEntriesCompletionHandlerResult {
            completionHandler(result.0)
        }
    }
    
    var invokedInformation = false
    var invokedInformationCount = 0
    var invokedInformationParameters: (identifier: Int, isShiny: Bool)?
    var invokedInformationParametersList = [(identifier: Int, isShiny: Bool)]()
    var stubbedInformationResult: (image: Data?, name: String)! = (nil, "")

    func information(for identifier: Int, isShiny: Bool) -> (image: Data?, name: String) {
        invokedInformation = true
        invokedInformationCount += 1
        invokedInformationParameters = (identifier, isShiny)
        invokedInformationParametersList.append((identifier, isShiny))
        return stubbedInformationResult
    }
}

class MockPokemonDetailRouter: PokemonDetailRouterInput {
    static func build(from coordinator: CoordinatorInput, services: PokemonDetailServices, identifier: Int, isShiny: Bool) -> UIViewController {
        fatalError("Dummy implementation")
    }
}

class MockPokemonDetailView: PokemonDetailViewInput {
    var invokedUpdateEntries = false
    var invokedUpdateEntriesCount = 0
    var invokedUpdateEntriesParameters: [(pokedex: [String], text: String)]?
    var invokedUpdateEntriesParametersList = [[(pokedex: [String], text: String)]]()
    
    func updateEntries(texts: [(pokedex: [String], text: String)]) {
        invokedUpdateEntries = true
        invokedUpdateEntriesCount += 1
        invokedUpdateEntriesParameters = texts
        invokedUpdateEntriesParametersList.append(texts)
    }
    
    var invokedSetupInitialState = false
    var invokedSetupInitialStateCount = 0
    var invokedSetupInitialStateParameters: (viewData: PokemonDetailViewData, Void)?
    var invokedSetupInitialStateParametersList = [(viewData: PokemonDetailViewData, Void)]()

    func setupInitialState(with viewData: PokemonDetailViewData) {
        invokedSetupInitialState = true
        invokedSetupInitialStateCount += 1
        invokedSetupInitialStateParameters = (viewData, ())
        invokedSetupInitialStateParametersList.append((viewData, ()))
    }
}
