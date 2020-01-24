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
            context("fetch local pokemon") {
                it("fetch list of pokemon") {
                    let list = Pokemon.fakePokemon
                    self.mockDatabase.stubbedAllPokemonResult = list

                    let pokemon = self.interactor.localPokemon()
                    expect(self.mockDatabase.invokedAllPokemon) == true
                    expect(pokemon) == list
                }
            }

            context("save pokemon") {
                it("saves a list of pokemon") {
                    let list = Pokemon.fakePokemon
                    self.interactor.save(pokemon: list)

                    expect(self.mockDatabase.invokedSave) == true
                    expect(self.mockDatabase.invokedSaveParameters?.pokemon) == list
                }
            }

            context("fetch images") {
                it("fetch default and shiny") {
                    let image = UIImage(named: "bulbasaur_default", in: Bundle(for: PokemonListInteractorSpec.self), compatibleWith: nil)!
                    var pokemon = Pokemon.fakePokemon.first!
                    pokemon.image = image.pngData()
                    pokemon.shiny = image.pngData()

                    self.mockNetworking.stubbedImageCompletionHandlerResult = (.success(image.pngData()!), ())
                    self.mockNetworking.stubbedPokemonResultAutomatically = true

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

                it("fails to fetch shiny") {
                    let image = UIImage(named: "bulbasaur_default", 
                                        in: Bundle(for: PokemonListInteractorSpec.self),
                                        compatibleWith: nil)!
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

                it("fails to fetch default image") {
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
            }

            context("fetch pokemon") {
                it("fetch from both database and network") {
                    self.mockNetworking.stubbedPokemonURLsCompletionHandlerResult = (.success(PokemonURL.fakeURLs.compactMap { $0.url }) ,())
                    self.mockNetworking.stubbedPokemonResultAutomatically = true

                    self.mockDatabase.stubbedAllPokemonResult = Array(Pokemon.fakePokemon[0..<5])
                    self.mockDatabase.stubbedAllPokemonResultAutomatically = true

                    let expectedResult: [Pokemon] = Pokemon.fakePokemon
                    var actualResult: [Pokemon] = []
                    var resultCount = 0
                    self.interactor.pokemon { result in
                        switch result {
                        case let .success(pokemon):
                            resultCount += 1
                            actualResult = pokemon
                        case .failure: XCTFail("Pokemon request shouldn't fail")
                        }
                    }

                    expect(self.mockDatabase.invokedAllPokemon) == true
                    expect(self.mockDatabase.invokedAllPokemonCount).toEventually(equal(2))

                    expect(self.mockNetworking.invokedPokemonURLs) == true
                    expect(self.mockNetworking.invokedPokemonURLsCount) == 1
                    expect(self.mockNetworking.invokedPokemonURLsParameters?.offset) == 5

                    expect(self.mockNetworking.invokedPokemonCount).toEventually(equal(10))

                    expect(self.mockDatabase.invokedSave).toEventually(equal(true))
                    expect(self.mockDatabase.invokedSaveParameters?.pokemon.count).toEventually(equal(15))

                    expect(resultCount).toEventually(equal(2))
                    expect(actualResult).toEventually(equal(expectedResult))
                }

                it("fetch from network") {
                    self.mockNetworking.stubbedPokemonURLsCompletionHandlerResult = (.success(PokemonURL.fakeURLs.compactMap { $0.url }) ,())
                    self.mockNetworking.stubbedPokemonResultAutomatically = true

                    self.mockDatabase.stubbedAllPokemonResult = []
                    self.mockDatabase.stubbedAllPokemonResultAutomatically = true

                    let expectedResult: [Pokemon] = Pokemon.fakePokemon
                    var actualResult: [Pokemon] = []
                    var resultCount = 0
                    self.interactor.pokemon { result in
                        switch result {
                        case let .success(pokemon):
                            resultCount += 1
                            actualResult = pokemon
                        case .failure: XCTFail("Pokemon request shouldn't fail")
                        }
                    }

                    expect(self.mockDatabase.invokedAllPokemon) == true
                    expect(self.mockDatabase.invokedAllPokemonCount).toEventually(equal(2))

                    expect(self.mockNetworking.invokedPokemonURLs) == true
                    expect(self.mockNetworking.invokedPokemonURLsCount) == 1
                    expect(self.mockNetworking.invokedPokemonURLsParameters?.offset) == 0

                    expect(self.mockNetworking.invokedPokemonCount).toEventually(equal(10))

                    expect(self.mockDatabase.invokedSave).toEventually(equal(true))
                    expect(self.mockDatabase.invokedSaveParameters?.pokemon.count).toEventually(equal(10))

                    expect(resultCount).toEventually(equal(1))
                    expect(actualResult).toEventually(equal(expectedResult))
                }

                it("fetch from database") {
                    self.mockNetworking.stubbedPokemonURLsCompletionHandlerResult = (.failure(.noNetwork) ,())
                    self.mockNetworking.stubbedPokemonResultAutomatically = false

                    self.mockDatabase.stubbedAllPokemonResult = Array(Pokemon.fakePokemon[0..<5])
                    self.mockDatabase.stubbedAllPokemonResultAutomatically = false

                    let expectedResult: [Pokemon] = Array(Pokemon.fakePokemon[0..<5])
                    var actualResult: [Pokemon] = []
                    var resultCount = 0
                    var failureCount = 0
                    self.interactor.pokemon { result in
                        switch result {
                        case let .success(pokemon):
                            resultCount += 1
                            actualResult = pokemon
                        case .failure: failureCount += 1
                        }
                    }

                    expect(self.mockDatabase.invokedAllPokemon) == true
                    expect(self.mockDatabase.invokedAllPokemonCount).toEventually(equal(1))

                    expect(self.mockNetworking.invokedPokemonURLs) == true
                    expect(self.mockNetworking.invokedPokemonURLsCount) == 1
                    expect(self.mockNetworking.invokedPokemonURLsParameters?.offset) == 5

                    expect(resultCount).toEventually(equal(1))
                    expect(failureCount).toEventually(equal(1))
                    expect(actualResult).toEventually(equal(expectedResult))
                }

                it("fetch last page") {
                    self.mockNetworking.stubbedPokemonURLsCompletionHandlerResult = (.success([]) ,())
                    self.mockNetworking.stubbedPokemonResultAutomatically = true

                    self.mockDatabase.stubbedAllPokemonResult = Array(Pokemon.fakePokemon[0..<5])
                    self.mockDatabase.stubbedAllPokemonResultAutomatically = true

                    let expectedResult: [Pokemon] = Array(Pokemon.fakePokemon[0..<5])
                    var actualResult: [Pokemon] = []
                    var resultCount = 0
                    self.interactor.pokemon { result in
                        switch result {
                        case let .success(pokemon):
                            resultCount += 1
                            actualResult = pokemon
                        case .failure: XCTFail("Pokemon request shouldn't fail")
                        }
                    }

                    expect(self.mockDatabase.invokedAllPokemon) == true
                    expect(self.mockDatabase.invokedAllPokemonCount).toEventually(equal(2))

                    expect(self.mockNetworking.invokedPokemonURLs) == true
                    expect(self.mockNetworking.invokedPokemonURLsCount) == 1
                    expect(self.mockNetworking.invokedPokemonURLsParameters?.offset) == 5

                    expect(self.mockNetworking.invokedPokemon).toEventually(equal(false))

                    expect(self.mockDatabase.invokedSave).toEventually(equal(true))
                    expect(self.mockDatabase.invokedSaveParameters?.pokemon.count).toEventually(equal(5))

                    expect(resultCount).toEventually(equal(2))
                    expect(actualResult).toEventually(equal(expectedResult))
                }

                it("fails to fetch a pokemon") {
                    self.mockNetworking.stubbedPokemonURLsCompletionHandlerResult = (.failure(.noNetwork) ,())
                    self.mockNetworking.stubbedPokemonResultAutomatically = false

                    self.mockDatabase.stubbedAllPokemonResult = []

                    let expectedResult: PokemonListInteractorErrors = .networking(NetworkingServiceError.noNetwork)
                    var actualResult: PokemonListInteractorErrors?
                    self.interactor.pokemon { result in
                        switch result {
                        case .success: XCTFail("Pokemon request shouldn't success")
                        case let .failure(error): actualResult = error
                        }
                    }

                    expect(self.mockDatabase.invokedAllPokemon) == true
                    expect(self.mockDatabase.invokedAllPokemonCount).toEventually(equal(1))

                    expect(self.mockNetworking.invokedPokemonURLs) == true
                    expect(self.mockNetworking.invokedPokemonURLsCount) == 1
                    expect(self.mockNetworking.invokedPokemonURLsParameters?.offset) == 0

                    expect(actualResult).toEventually(equal(expectedResult))
                }
            }
        }
    }
}

class MockPokemonListInteractorOutput: PokemonListInteractorOutput {}
