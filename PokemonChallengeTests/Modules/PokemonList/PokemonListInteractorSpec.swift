// 
//  PokemonListInteractorSpec.swift
//  PokemonChallengeTests
//
//  Created by Felipe Docil on 24/11/2019.
//  Copyright © 2019 Felipe Docil. All rights reserved.
//

@testable import PokemonChallenge
import Nimble
import Quick

class PokemonListInteractorSpec: QuickSpec {
    var mockNetworking: MockPokemonListNetworking!
    var mockDatabase: MockPokemonListDatabase!
    var interactor: PokemonListInteractor!
    
    override func spec() {
        beforeEach {
            self.mockNetworking = MockPokemonListNetworking()
            self.mockDatabase = MockPokemonListDatabase()
            
            let mockServices = PokemonListServices(networking: self.mockNetworking, database: self.mockDatabase)
            let output = MockPokemonListInteractorOutput()

            self.interactor = PokemonListInteractor()
            self.interactor.services = mockServices
            self.interactor.output = output
        }
        describe("PokemonListInteractorSpec") {
            it("fetches pokemon successfuly from both database and networking") {
                self.mockNetworking.stubbedPokemonURLsCompletionHandlerResult = (.success(PokemonURL.fakeURLs.compactMap { $0.url }) ,())
                self.mockNetworking.shouldReturnSuccess = true
                
                self.mockDatabase.stubbedFetchAllPokemonResult = Array(Pokemon.fakePokemon[0..<5])
                
                let expectedResult: Set<Pokemon> = Set(Pokemon.fakePokemon)
                var actualResult: Set<Pokemon> = Set()
                self.interactor.pokemon { result in
                    switch result {
                    case let .success(pokemon): actualResult = pokemon
                    case .failure: XCTFail("Pokemon request shouldn't fail")
                    }
                }
                
                expect(self.mockDatabase.invokedFetchAllPokemon) == true
                expect(self.mockNetworking.invokedPokemonURLs) == true
                expect(self.mockNetworking.invokedPokemonCount).toEventually(equal(10))
                expect(actualResult).toEventually(equal(expectedResult))
            }
            
            it("fetches pokemon successfuly only for networking") {
                self.mockNetworking.stubbedPokemonURLsCompletionHandlerResult = (.success(PokemonURL.fakeURLs.compactMap { $0.url }) ,())
                self.mockNetworking.shouldReturnSuccess = true
                
                self.mockDatabase.stubbedFetchAllPokemonResult = []
                
                let expectedResult: Set<Pokemon> = Set(Pokemon.fakePokemon)
                var actualResult: Set<Pokemon> = Set()
                self.interactor.pokemon { result in
                    switch result {
                    case let .success(pokemon): actualResult = pokemon
                    case .failure: XCTFail("Pokemon request shouldn't fail")
                    }
                }
                
                expect(self.mockDatabase.invokedFetchAllPokemon) == true
                expect(self.mockNetworking.invokedPokemonURLs) == true
                expect(self.mockNetworking.invokedPokemonCount).toEventually(equal(10))
                expect(actualResult).toEventually(equal(expectedResult))
            }
            
            it("fetches pokemon successfuly only for database") {
                self.mockNetworking.stubbedPokemonURLsCompletionHandlerResult = (.failure(.noNetwork) ,())
                self.mockNetworking.shouldReturnSuccess = false
                
                self.mockDatabase.stubbedFetchAllPokemonResult = Array(Pokemon.fakePokemon[0..<5])
                
                let expectedResult: Set<Pokemon> = Set(Array(Pokemon.fakePokemon[0..<5]))
                var actualResult: Set<Pokemon> = Set()
                var failureCount = 0
                self.interactor.pokemon { result in
                    switch result {
                    case let .success(pokemon): actualResult = pokemon
                    case .failure: failureCount = failureCount+1
                    }
                }
                
                expect(self.mockDatabase.invokedFetchAllPokemon) == true
                expect(self.mockNetworking.invokedPokemonURLs) == true
                expect(failureCount).toEventually(equal(1))
                expect(failureCount).toNotEventually(equal(2))
                expect(actualResult).toEventually(equal(expectedResult))
            }
            
            it("fails to fetch pokemon") {
                self.mockNetworking.stubbedPokemonURLsCompletionHandlerResult = (.failure(.noNetwork) ,())
                self.mockNetworking.shouldReturnSuccess = false
                
                self.mockDatabase.stubbedFetchAllPokemonResult = []
                
                let expectedResult: PokemonListInteractorErrors = .networking(NetworkingServiceError.noNetwork)
                var actualResult: PokemonListInteractorErrors?
                self.interactor.pokemon { result in
                    switch result {
                    case .success: XCTFail("Pokemon request shouldn't success")
                    case let .failure(error): actualResult = error
                    }
                }
                
                expect(self.mockDatabase.invokedFetchAllPokemon) == true
                expect(self.mockNetworking.invokedPokemonURLs) == true
                expect(actualResult).toEventually(equal(expectedResult))
            }
            
            it("fetches image successfuly") {
                let image = UIImage(named: "bulbasaur_default", in: Bundle(for: PokemonListInteractorSpec.self), compatibleWith: nil)!
                var pokemon = Pokemon.fakePokemon.first!
                pokemon.image = image.pngData()
                pokemon.shiny = image.pngData()
                
                self.mockNetworking.stubbedImageCompletionHandlerResult = (.success(image.pngData()!), ())
                self.mockNetworking.shouldReturnSuccess = true
                                
                let expectedResult: Pokemon = pokemon
                var actualResult: Pokemon?
                self.interactor.images(for: pokemon) { result in
                    switch result {
                    case let .success(pokemonWithImage): actualResult = pokemonWithImage
                    case .failure: XCTFail("Image request shouldn't fail")
                    }
                }
                
                expect(self.mockNetworking.invokedImage) == true
                expect(self.mockNetworking.invokedImageCount).toEventually(equal(2))
                expect(actualResult).toEventually(equal(expectedResult))
            }
            
            it("fails to fetch shiny image") {
                let image = UIImage(named: "bulbasaur_default", in: Bundle(for: PokemonListInteractorSpec.self), compatibleWith: nil)!
                var pokemon = Pokemon.fakePokemon.first!
                pokemon.image = image.pngData()
                pokemon.shiny = nil
                
                self.mockNetworking.stubbedImageCompletionHandlerResult = (.success(image.pngData()!), ())
                self.mockNetworking.shouldFailOnShiny = true
                                
                let expectedResult: Pokemon = pokemon
                var actualResult: Pokemon?
                self.interactor.images(for: pokemon) { result in
                    switch result {
                    case let .success(pokemonWithImage): actualResult = pokemonWithImage
                    case .failure: XCTFail("Image request shouldn't fail")
                    }
                }
                
                expect(self.mockNetworking.invokedImage) == true
                expect(self.mockNetworking.invokedImageCount).toEventually(equal(2))
                expect(actualResult).toEventually(equal(expectedResult))
            }
            
            it("fails to fetch image") {
                let pokemon = Pokemon.fakePokemon.first!
                
                self.mockNetworking.stubbedImageCompletionHandlerResult = (.failure(.noNetwork), ())
                self.mockNetworking.shouldFailOnShiny = true
                                
                let expectedResult: PokemonListInteractorErrors = .noImage
                var actualResult: PokemonListInteractorErrors?
                self.interactor.images(for: pokemon) { result in
                    switch result {
                    case .success: XCTFail("Image request shouldn't success")
                    case let .failure(error): actualResult = error
                    }
                }
                
                expect(self.mockNetworking.invokedImage) == true
                expect(self.mockNetworking.invokedImageCount).toEventually(equal(1))
                expect(actualResult).toEventually(equal(expectedResult))
            }
            
            it("saves pokemon list") {
                let pokemon = Pokemon.fakePokemon
                
                self.interactor.save(pokemon: pokemon) {}
                
                expect(self.mockDatabase.invokedInsertPokemon).toEventually(beTrue())
                expect(self.mockDatabase.invokedInsertPokemonCount).toEventually(equal(pokemon.count))
            }
        }
    }
}

class MockPokemonListInteractorOutput: PokemonListInteractorOutput {}
