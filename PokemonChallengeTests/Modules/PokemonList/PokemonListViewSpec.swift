// 
//  PokemonListViewSpec.swift
//  PokemonChallengeTests
//
//  Created by Felipe Docil on 24/11/2019.
//  Copyright © 2019 Felipe Docil. All rights reserved.
//

@testable import PokemonChallenge
import Nimble
import Quick
import SnapshotTesting
import SnapshotTesting_Nimble

class PokemonListViewSpec: QuickSpec {
    let mockDataSource: [PokemonListViewData] = [
        PokemonListViewData(identifier: 1,
                            image: UIImage(named: "bulbasaur_default", in: Bundle(for: PokemonCardSpec.self), compatibleWith: nil)!.pngData(),
                            shiny: UIImage(named: "bulbasaur_shiny", in: Bundle(for: PokemonCardSpec.self), compatibleWith: nil)!.pngData(),
                            name: "Bulbasaur"),
        PokemonListViewData(identifier: 4,
                            image: UIImage(named: "charmander_default", in: Bundle(for: PokemonCardSpec.self), compatibleWith: nil)!.pngData(),
                            shiny: UIImage(named: "charmander_shiny", in: Bundle(for: PokemonCardSpec.self), compatibleWith: nil)!.pngData(),
                            name: "Charmander"),
        PokemonListViewData(identifier: 7,
                            image: UIImage(named: "squirtle_default", in: Bundle(for: PokemonCardSpec.self), compatibleWith: nil)!.pngData(),
                            shiny: UIImage(named: "squirtle_shiny", in: Bundle(for: PokemonCardSpec.self), compatibleWith: nil)!.pngData(),
                            name: "Squirtle")
    ]
    
    override func spec() {
        describe("PokemonListViewSpec") {
            beforeSuite {
                // Snapshots must be compared using a simulator with the same OS, device as the simulator that originally took the reference
                self.verifyDevice()
            }
            it("snapshot the initial view") {
                let mockPresenter = MockPokemonListPresenter()
                mockPresenter.stubbedNumberOfItemsResult = self.mockDataSource.count
                mockPresenter.stubbedCardInformationResult = self.mockDataSource
                
                let view = PokemonListView(presenter: mockPresenter)
                view.setupInitialState()
                
                let navigationController = UINavigationController(rootViewController: view)

                record = false
                expect(navigationController).to(haveValidSnapshot(as: .image(on: .iPhoneSe), named: "iPhoneSE"))
                expect(navigationController).to(haveValidSnapshot(as: .image(on: .iPhone8), named: "iPhone8"))
                expect(navigationController).to(haveValidSnapshot(as: .image(on: .iPhone8Plus), named: "iPhone8Plus"))
                expect(navigationController).to(haveValidSnapshot(as: .image(on: .iPhone11), named: "iPhone11"))
                expect(navigationController).to(haveValidSnapshot(as: .image(on: .iPhone11Pro), named: "iPhone11Pro"))
            }
        }
    }
}

class MockPokemonListPresenter: PokemonListPresenterInput {
    var invokedReachEndOfPage = false
    var invokedReachEndOfPageCount = 0
    
    func reachEndOfPage() {
        invokedReachEndOfPage = true
        invokedReachEndOfPageCount += 1
    }
    
    var invokedViewIsReady = false
    var invokedViewIsReadyCount = 0
    
    func viewIsReady() {
        invokedViewIsReady = true
        invokedViewIsReadyCount += 1
    }
    
    var invokedViewDidAppear = false
    var invokedViewDidAppearCount = 0
    
    func viewDidAppear() {
        invokedViewDidAppear = true
        invokedViewDidAppearCount += 1
    }
    
    var invokedNumberOfItems = false
    var invokedNumberOfItemsCount = 0
    var stubbedNumberOfItemsResult: Int! = 0
    
    func numberOfItems() -> Int {
        invokedNumberOfItems = true
        invokedNumberOfItemsCount += 1
        return stubbedNumberOfItemsResult
    }
    
    var invokedCardInformation = false
    var invokedCardInformationCount = 0
    var invokedCardInformationParameters: (index: Int, Void)?
    var invokedCardInformationParametersList = [(index: Int, Void)]()
    var stubbedCardInformationResult: [PokemonListViewData] = []
    
    func cardInformation(for index: Int) -> PokemonListViewData {
        invokedCardInformation = true
        invokedCardInformationCount += 1
        invokedCardInformationParameters = (index, ())
        invokedCardInformationParametersList.append((index, ()))
        return stubbedCardInformationResult[index]
    }
    
    var invokedDidSelected = false
    var invokedDidSelectedCount = 0
    var invokedDidSelectedParameters: (row: Int, switchSelected: Bool, Void)?
    var invokedDidSelectedParametersList = [(row: Int, switchSelected: Bool, Void)]()
    
    func didSelected(row: Int, switchSelected: Bool) {
        invokedDidSelected = true
        invokedDidSelectedCount += 1
        invokedDidSelectedParameters = (row, switchSelected, ())
        invokedDidSelectedParametersList.append((row, switchSelected, ()))
    }
    
    var invokedSearch = false
    var invokedSearchCount = 0
    var invokedSearchParameters: (term: String, Void)?
    var invokedSearchParametersList = [(term: String, Void)]()
    
    func search(for term: String) {
        invokedSearch = true
        invokedSearchCount += 1
        invokedSearchParameters = (term, ())
        invokedSearchParametersList.append((term, ()))
    }
    
    func updateImages(for identifier: Int) {
        fatalError("Dummy implementation")
    }
}
