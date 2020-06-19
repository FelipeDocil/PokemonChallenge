//
//  DatabaseServiceSpec.swift
//  PokemonChallengeTests
//
//  Created by Felipe Docil on 02/12/2019.
//  Copyright © 2019 Felipe Docil. All rights reserved.
//

@testable import PokemonChallenge
import Nimble
import Quick
import RealmSwift

class DatabaseServiceSpec: QuickSpec {
    var service: NetworkingService!
    
    override func spec() {
        beforeEach {
            self.flushDatabase()
        }
        describe("DatabaseService Spec") {
            
            context("Success path") {
                it("successfuly fetch all pokemon") {
                    self.initDatabase()
                    
                    let service = DatabaseService(type: .inMemory)
                    
                    let pokemon = service.fetchAllPokemon()
                    expect(pokemon.count) == 10
                }
                
                it("insert pokemon") {
                    let service = DatabaseService()
                    
                    let pokemon = Pokemon.fakePokemon.first!
                    let cached = service.insertPokemon(pokemon: pokemon)
                    
                    expect(cached).toNot(beNil())
                }
                
                it("insert existing pokemon") {
                    self.initDatabase()
                    
                    let service = DatabaseService(type: .inMemory)
                    
                    let pokemon = Pokemon.fakePokemon.first!
                    let cached = service.insertPokemon(pokemon: pokemon)
                    
                    expect(cached).toNot(beNil())
                }
                
                it("fetch empty list") {
                    let service = DatabaseService(type: .inMemory)
                    
                    let pokemon = service.fetchAllPokemon()
                    
                    expect(pokemon.count) == 0
                }
                
                it("update image from existing pokemon") {
                    self.initDatabase()
                    let service = DatabaseService(type: .inMemory)
                    
                    let image = UIImage(named: "bulbasaur_default", in: Bundle(for: PokemonCardSpec.self), compatibleWith: nil)!.pngData()
                    let shiny = UIImage(named: "bulbasaur_shiny", in: Bundle(for: PokemonCardSpec.self), compatibleWith: nil)!.pngData()
                    var pokemon = Pokemon.fakePokemon.first!
                    pokemon.image = image
                    
                    let cached = service.insertPokemon(pokemon: pokemon)
                    
                    expect(cached).toNot(beNil())
                    expect(cached.image).toNot(beNil())
                    
                    var newPokemon = cached.toPokemon()!
                    newPokemon.shiny = shiny
                    
                    let newCached = service.insertPokemon(pokemon: newPokemon)
                    expect(newCached).toNot(beNil())
                    expect(newCached.image).toNot(beNil())
                    expect(newCached.shiny).toNot(beNil())
                }
                
                it("fetches a single pokemon") {
                    self.initDatabase()
                    let service = DatabaseService(type: .inMemory)
                    
                    let pokemon = service.pokemon(identifier: 4)
                    
                    expect(pokemon).toNot(beNil())
                    expect(pokemon?.name) == "charmander"
                }
                
                it("update entries from existing pokemon") {
                    self.initDatabase()
                    let service = DatabaseService(type: .inMemory)
                    
                    let entries = Entry.fakeEntries
                    var pokemon = Pokemon.fakePokemon.first!
                    pokemon.entry = entries
                    
                    let cached = service.insertPokemon(pokemon: pokemon)
                    
                    expect(cached).toNot(beNil())
//                    expect(cached.entry?.isEmpty) == false
                }
            }
        }
    }
    
    private func initDatabase() {
        func insert(pokemon: Pokemon) -> PokemonRealm {
            let obj = PokemonRealm()
            obj.fill(with: pokemon)
            
            return obj
        }
        
        let realm = try! Realm(configuration: .init(inMemoryIdentifier: "realm_in_memmory"))
        
        for pokemon in Pokemon.fakePokemon {
            let obj = insert(pokemon: pokemon)
            expect(obj).toNot(beNil())
            
            do {
                try realm.write {
                    realm.add(obj, update: .modified)
                }
            } catch {
                print("💥 Save on test \(pokemon.name) error \(error)")
            }
        }
    }
    
    private func flushDatabase() {
        let realm = try! Realm(configuration: .init(inMemoryIdentifier: "realm_in_memmory"))
        try! realm.write {
            realm.deleteAll()
        }
    }
}
