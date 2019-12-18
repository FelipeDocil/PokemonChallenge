// 
//  PokemonDetailViewSpec.swift
//  PokemonChallengeTests
//
//  Created by Felipe Docil on 04/12/2019.
//  Copyright © 2019 Felipe Docil. All rights reserved.
//

@testable import PokemonChallenge
import Nimble
import Quick
import SnapshotTesting
import SnapshotTesting_Nimble

class PokemonDetailViewSpec: QuickSpec {
    var mockPresenter: MockPokemonDetailPresenter!
    var view: PokemonDetailView!
    
    let entries = [
        (pokedex: ["x"], text: "A strange seed was planted on its back at birth. The plant sprouts and grows with this Pokémon."),
        (pokedex: ["alpha-saphire", "omega-ruby"], text: "Bulbasaur can be seen napping in the bright sunlight. There is a seed on its back. By soaking up the sun's ray, the seed grows progressively larger."),
        (pokedex: ["firered"], text: "There is a plant seed on its back right from the day this POKéMON is born. The seed slowly grows larger"),
    ]
    
    override func spec() {
        beforeEach {
            self.mockPresenter = MockPokemonDetailPresenter()
            self.view = PokemonDetailView(presenter: self.mockPresenter)
        }
        describe("PokemonDetailViewSpec") {
            beforeSuite {
                // Snapshots must be compared using a simulator with the same OS, device as the simulator that originally took the reference
                self.verifyDevice()
            }
            it("snapshot the initial view") {
                let image = UIImage(named: "bulbasaur_default", in: Bundle(for: PokemonCardSpec.self), compatibleWith: nil)!.pngData()
                let viewData = PokemonDetailViewData(image: image, name: "bulbasaur", isShiny: false)
                
                self.view.setupInitialState(with: viewData)
                self.view.updateEntries(texts: self.entries)
                
                let navigationController = UINavigationController(rootViewController: self.view)

                record = false
                expect(navigationController).to(haveValidSnapshot(as: .image(on: .iPhoneSe), named: "iPhoneSE"))
                expect(navigationController).to(haveValidSnapshot(as: .image(on: .iPhone8), named: "iPhone8"))
                expect(navigationController).to(haveValidSnapshot(as: .image(on: .iPhone8Plus), named: "iPhone8Plus"))
                expect(navigationController).to(haveValidSnapshot(as: .image(on: .iPhone11), named: "iPhone11"))
                expect(navigationController).to(haveValidSnapshot(as: .image(on: .iPhone11Pro), named: "iPhone11Pro"))
            }
            
            it("snapshot the initial view if shiny was selected") {
                let image = UIImage(named: "bulbasaur_shiny", in: Bundle(for: PokemonCardSpec.self), compatibleWith: nil)!.pngData()
                let viewData = PokemonDetailViewData(image: image, name: "bulbasaur", isShiny: true)
                
                self.view.setupInitialState(with: viewData)
                self.view.updateEntries(texts: self.entries)
                
                let navigationController = UINavigationController(rootViewController: self.view)

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

class MockPokemonDetailPresenter: PokemonDetailPresenterInput {
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
}
