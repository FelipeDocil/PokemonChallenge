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
            context("fetch all pokemon") {
                it("fetch with initial database") {
                    self.initDatabase()

                    let service = DatabaseService(container: self.mockPersistentContainer)
                    let all = service.allPokemon()

                    expect(all.count) == 10
                }

                it("fetch an empy list") {
                    let service = DatabaseService(container: self.mockPersistentContainer)
                    let all = service.allPokemon()

                    expect(all.count) == 0
                }
            }

            context("fetch a single pokemon") {
                it("fetch an existing pokemon") {
                    self.initDatabase()

                    let service = DatabaseService(container: self.mockPersistentContainer)
                    let pokemon = service.pokemon(identifier: 4)

                    expect(pokemon).toNot(beNil())
                    expect(pokemon?.name) == "charmander"
                }

                it("fetch an non-existent pokemon") {
                    self.initDatabase()

                    let service = DatabaseService(container: self.mockPersistentContainer)
                    let pokemon = service.pokemon(identifier: 9999)

                    expect(pokemon).to(beNil())
                }
            }

            context("save pokemon") {
                it("insert a new pokemon") {
                    let service = DatabaseService(container: self.mockPersistentContainer)
                    let pokemon = Pokemon.fakePokemon

                    service.save(pokemon: pokemon)

                    let all = service.allPokemon()
                    expect(all.count) == 10
                }

                it("insert existing pokemon") {
                    self.initDatabase()

                    let service = DatabaseService(container: self.mockPersistentContainer)
                    let pokemon = Pokemon.fakePokemon.first!

                    service.save(pokemon: [pokemon])

                    let all = service.allPokemon()
                    expect(all.count) == 10
                }

                it("update existing pokemon") {
                    self.initDatabase()

                    let service = DatabaseService(container: self.mockPersistentContainer)
                    var pokemon = Pokemon.fakePokemon.first!
                    let image = UIImage(named: "bulbasaur_default", 
                                        in: Bundle(for: DatabaseServiceSpec.self),
                                        compatibleWith: nil)!
                    pokemon.image = image.pngData()

                    service.save(pokemon: [pokemon])

                    let itemWithImage = service.pokemon(identifier: pokemon.identifier)
                    expect(itemWithImage).toNot(beNil())
                    expect(itemWithImage?.image).toNot(beNil())

                    let shiny = UIImage(named: "bulbasaur_shiny",
                                        in: Bundle(for: DatabaseServiceSpec.self),
                                        compatibleWith: nil)!
                    pokemon.shiny = shiny.pngData()

                    service.save(pokemon: [pokemon])

                    let itemWithShiny = service.pokemon(identifier: pokemon.identifier)
                    expect(itemWithShiny).toNot(beNil())
                    expect(itemWithShiny?.image).toNot(beNil())
                    expect(itemWithShiny?.shiny).toNot(beNil())
                }

                it("update and add new pokemon") {
                    let service = DatabaseService(container: self.mockPersistentContainer)
                    let initialList = Array(Pokemon.fakePokemon[0...5])

                    service.save(pokemon: initialList)

                    var newList = Array(Pokemon.fakePokemon[3...8])
                    let image = UIImage(named: "bulbasaur_default",
                                        in: Bundle(for: DatabaseServiceSpec.self),
                                        compatibleWith: nil)!
                    let shiny = UIImage(named: "bulbasaur_shiny",
                                        in: Bundle(for: DatabaseServiceSpec.self),
                                        compatibleWith: nil)!
                    var pokemon = newList.first!
                    pokemon.image = image.pngData()
                    pokemon.shiny = shiny.pngData()
                    newList[0] = pokemon

                    service.save(pokemon: newList)

                    let all = service.allPokemon()
                    expect(all.count) == 9

                    let item = service.pokemon(identifier: pokemon.identifier)
                    expect(item?.image).toNot(beNil())
                    expect(item?.shiny).toNot(beNil())
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
