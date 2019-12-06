// 
//  PokemonDetailInteractorSpec.swift
//  PokemonChallengeTests
//
//  Created by Felipe Docil on 04/12/2019.
//  Copyright © 2019 Felipe Docil. All rights reserved.
//

@testable import PokemonChallenge
import Nimble
import Quick

class PokemonDetailInteractorSpec: QuickSpec {
    var mockNetworking: MockPokemonDetailNetworking!
    var mockDatabase: MockPokemonDetailDatabase!
    var interactor: PokemonDetailInteractor!
    
    override func spec() {
        beforeEach {
            self.mockNetworking = MockPokemonDetailNetworking()
            self.mockDatabase = MockPokemonDetailDatabase()
            
            let mockServices = PokemonDetailServices(networking: self.mockNetworking, database: self.mockDatabase)
            let output = MockPokemonDetailInteractorOutput()

            self.interactor = PokemonDetailInteractor()
            self.interactor.services = mockServices
            self.interactor.output = output
        }
        describe("PokemonDetailInteractorSpec") {
            it("fetch pokemon") {
                let image = UIImage(named: "bulbasaur_default", in: Bundle(for: PokemonCardSpec.self), compatibleWith: nil)!.pngData()
                var pokemon = Pokemon.fakePokemon.first!
                pokemon.image = image
                
                self.mockDatabase.stubbedPokemonResult = pokemon
                let expectedInformation = (image: image, name: "bulbasaur")
                
                let actualInformation = self.interactor.information(for: 1, isShiny: false)
                
                expect(actualInformation.image) == expectedInformation.image
                expect(actualInformation.name) == expectedInformation.name
            }
            
            it("fetch shiny pokemon") {
                let image = UIImage(named: "bulbasaur_shiny", in: Bundle(for: PokemonCardSpec.self), compatibleWith: nil)!.pngData()
                var pokemon = Pokemon.fakePokemon.first!
                pokemon.shiny = image
                
                self.mockDatabase.stubbedPokemonResult = pokemon
                let expectedInformation = (image: image, name: "bulbasaur")
                
                let actualInformation = self.interactor.information(for: 1, isShiny: true)
                
                expect(actualInformation.image) == expectedInformation.image
                expect(actualInformation.name) == expectedInformation.name
            }
        }
    }
}

class MockPokemonDetailInteractorOutput: PokemonDetailInteractorOutput {}
