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
            
            it("fetches entries") {
                let entries = Entry.fakeEntries
                let pokemon = Pokemon.fakePokemon.first!
                
                self.mockDatabase.stubbedPokemonResult = pokemon
                self.mockNetworking.stubbedEntriesCompletionHandlerResult = (.success(entries), ())
                
                var actualEntries: [Entry] = []
                self.interactor.fetchEntries(for: 1) { result in
                    switch result {
                    case let .success(entries): actualEntries = entries
                    case .failure: XCTFail("Fetch entries shouldn't fail")
                    }
                }
                
                expect(self.mockDatabase.invokedPokemon) == true
                expect(self.mockDatabase.invokedPokemonParameters?.identifier) == 1
                expect(self.mockNetworking.invokedEntries) == true
                expect(self.mockNetworking.invokedEntriesParameters?.urlPath) == pokemon.pokedexPath.absoluteString
                expect(actualEntries).toEventually(equal(entries))
            }
            
            it("fetches entries from database") {
                let entries = Entry.fakeEntries
                var pokemon = Pokemon.fakePokemon.first!
                pokemon.entry = entries
                
                self.mockDatabase.stubbedPokemonResult = pokemon
                self.mockNetworking.stubbedEntriesCompletionHandlerResult = (.success(entries), ())
                
                var actualEntries: [Entry] = []
                self.interactor.fetchEntries(for: 1) { result in
                    switch result {
                    case let .success(entries): actualEntries = entries
                    case .failure: XCTFail("Fetch entries shouldn't fail")
                    }
                }
                
                expect(self.mockDatabase.invokedPokemon) == true
                expect(self.mockDatabase.invokedPokemonParameters?.identifier) == 1
                expect(self.mockNetworking.invokedEntries) == false
                expect(actualEntries).toEventually(equal(entries))
            }
            
            it("handles error on fetch entries") {
                self.mockDatabase.stubbedPokemonResult = nil
                
                let databaseError = PokemonDetailInteractorErrors.noPokemon
                var actualError: PokemonDetailInteractorErrors?
                self.interactor.fetchEntries(for: 1) { result in
                    switch result {
                    case .success: XCTFail("Fetch entries should fail")
                    case let .failure(error): actualError = error
                    }
                }
                
                expect(self.mockDatabase.invokedPokemon) == true
                expect(self.mockDatabase.invokedPokemonParameters?.identifier) == 1
                expect(actualError?.localizedDescription).toEventually(equal(databaseError.localizedDescription))
                
                let pokemon = Pokemon.fakePokemon.first!
                let networkError = PokemonDetailInteractorErrors.networking(NetworkingServiceError.noNetwork)
                
                self.mockDatabase.stubbedPokemonResult = pokemon
                self.mockNetworking.stubbedEntriesCompletionHandlerResult = (.failure(.noNetwork) , ())
                
                self.interactor.fetchEntries(for: 1) { result in
                    switch result {
                    case .success: XCTFail("Fetch entries should fail")
                    case let .failure(error): actualError = error
                    }
                }
                
                expect(self.mockNetworking.invokedEntries) == true
                expect(self.mockNetworking.invokedEntriesParameters?.urlPath) == pokemon.pokedexPath.absoluteString
                expect(actualError?.localizedDescription).toEventually(equal(networkError.localizedDescription))
                
            }
            
            it("save pokemon") {
                let entries = Entry.fakeEntries
                var pokemon = Pokemon.fakePokemon.first!
                
                self.mockDatabase.stubbedPokemonResult = pokemon
                
                self.interactor.save(entries: entries, into: 1)
                
                expect(self.mockDatabase.invokedPokemon) == true
                expect(self.mockDatabase.invokedPokemonParameters?.identifier) == 1
                expect(self.mockDatabase.invokedInsertPokemon) == true
                
                pokemon.entry = entries
                
                expect(self.mockDatabase.invokedInsertPokemonParameters?.pokemon) == pokemon
            }
        }
    }
}

class MockPokemonDetailInteractorOutput: PokemonDetailInteractorOutput {}
