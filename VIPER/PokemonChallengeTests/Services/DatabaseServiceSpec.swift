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
import CoreData

class DatabaseServiceSpec: QuickSpec {
    lazy var mockPersistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PokemonChallenge")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false
        
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { description, error in
            precondition(description.type == NSInMemoryStoreType)
            
            if let error = error {
                fatalError("Create an in-mem coordinator failed \(error)")
            }
        }
        
        return container
    }()
    
    var service: NetworkingService!
    
    override func spec() {
        beforeEach {
            self.flushDatabase()
        }
        describe("DatabaseService Spec") {
            
            context("Success path") {
                it("successfuly fetch all pokemon") {
                    self.initDatabase()
                    
                    let service = DatabaseService(container: self.mockPersistentContainer)
                    
                    let pokemon = service.fetchAllPokemon()
                    expect(pokemon.count) == 10
                }
                
                it("insert pokemon") {
                    let service = DatabaseService(container: self.mockPersistentContainer)
                    
                    let pokemon = Pokemon.fakePokemon.first!
                    let cached = service.insertPokemon(pokemon: pokemon)
                    
                    expect(cached).toNot(beNil())
                }
                
                it("insert existing pokemon") {
                    self.initDatabase()
                    
                    let service = DatabaseService(container: self.mockPersistentContainer)
                    
                    let pokemon = Pokemon.fakePokemon.first!
                    let cached = service.insertPokemon(pokemon: pokemon)
                    
                    expect(cached).toNot(beNil())
                }
                
                it("fetch empty list") {
                    let service = DatabaseService(container: self.mockPersistentContainer)
                    
                    let pokemon = service.fetchAllPokemon()
                    
                    expect(pokemon.count) == 0
                }
                
                it("update image from existing pokemon") {
                    self.initDatabase()
                    let service = DatabaseService(container: self.mockPersistentContainer)
                    
                    let image = UIImage(named: "bulbasaur_default", in: Bundle(for: PokemonCardSpec.self), compatibleWith: nil)!.pngData()
                    let shiny = UIImage(named: "bulbasaur_shiny", in: Bundle(for: PokemonCardSpec.self), compatibleWith: nil)!.pngData()
                    var pokemon = Pokemon.fakePokemon.first!
                    pokemon.image = image
                    
                    let cached = service.insertPokemon(pokemon: pokemon)
                    
                    expect(cached).toNot(beNil())
                    expect(cached?.image).toNot(beNil())
                    
                    var newPokemon = cached!.toPokemon()!
                    newPokemon.shiny = shiny
                    
                    let newCached = service.insertPokemon(pokemon: newPokemon)
                    expect(newCached).toNot(beNil())
                    expect(newCached?.image).toNot(beNil())
                    expect(newCached?.shiny).toNot(beNil())
                }
                
                it("fetches a single pokemon") {
                    self.initDatabase()
                    let service = DatabaseService(container: self.mockPersistentContainer)
                    
                    let pokemon = service.pokemon(identifier: 4)
                    
                    expect(pokemon).toNot(beNil())
                    expect(pokemon?.name) == "charmander"
                }
                
                it("update entries from existing pokemon") {
                    self.initDatabase()
                    let service = DatabaseService(container: self.mockPersistentContainer)
                    
                    let entries = Entry.fakeEntries
                    var pokemon = Pokemon.fakePokemon.first!
                    pokemon.entry = entries
                    
                    let cached = service.insertPokemon(pokemon: pokemon)
                    
                    expect(cached).toNot(beNil())
                    expect(cached?.entry?.isEmpty) == false
                }
            }
        }
    }
    
    private func initDatabase() {
        func insert(pokemon: Pokemon) -> PokemonManaged? {
            let obj = NSEntityDescription.insertNewObject(forEntityName: "Pokemon", into: mockPersistentContainer.viewContext) as? PokemonManaged

            obj?.identifier = pokemon.identifier
            obj?.name = pokemon.name
            obj?.imagePath = pokemon.imagePath
            obj?.image = pokemon.image
            obj?.shinyPath = pokemon.shinyPath
            obj?.shiny = pokemon.shiny
            obj?.pokedexPath = pokemon.pokedexPath
            
            return obj
        }
        
        for pokemon in Pokemon.fakePokemon {
            let obj = insert(pokemon: pokemon)
            expect(obj).toNot(beNil())
        }
        
        do {
            try mockPersistentContainer.viewContext.save()
        }  catch {
            print("create fakes error \(error)")
        }
    }
    
    private func flushDatabase() {
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "Pokemon")
        let objs = try! mockPersistentContainer.viewContext.fetch(fetchRequest)
        for case let obj as NSManagedObject in objs {
            mockPersistentContainer.viewContext.delete(obj)
        }
        try! mockPersistentContainer.viewContext.save()
    }
}
