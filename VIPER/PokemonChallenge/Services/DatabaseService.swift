//
//  DatabaseService.swift
//  PokemonChallenge
//
//  Created by Felipe Docil on 23/11/2019.
//  Copyright © 2019 Felipe Docil. All rights reserved.
//

import Foundation
import CoreData

protocol DatabaseServiceInput {
    @discardableResult
    func allPokemon() -> [Pokemon]
    func pokemon(identifier: Int) -> Pokemon?
    func save(pokemon: [Pokemon])
    func save(entries: [Entry], to pokemon: Pokemon)
}

class DatabaseService: DatabaseServiceInput {
    var persistentContainer: NSPersistentContainer

    lazy var backgroundContext: NSManagedObjectContext = {
        let tmpContext = persistentContainer.newBackgroundContext()
        tmpContext.automaticallyMergesChangesFromParent = true
        tmpContext.name = "background context"

        return tmpContext
    }()

    init(container: NSPersistentContainer) {
        self.persistentContainer = container
        self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    }

    // MARK: DatabaseService Input
    func save(pokemon list: [Pokemon]) {
        let context = backgroundContext
        context.performAndWait {
            // Get all local
            let request = NSFetchRequest<PokemonManaged>(entityName: "Pokemon")
            let local: [PokemonManaged] = (try? context.fetch(request)) ?? []

            // Filter for only changes
            let filtered = list.filter { pokemon in
                let first = local.first { $0.identifier == pokemon.identifier }
                return first == nil ||
                       (first?.image == nil && pokemon.image != nil) ||
                       (first?.shiny == nil && pokemon.image != nil)
            }

            let splitFiltered = filtered.separate { item in
                let first = local.first { $0.identifier == item.identifier }
                return first != nil
            }

            // Update the existing one
            let toUpdate = splitFiltered.matching.compactMap { pokemon in
                (object: local.first { $0.identifier == pokemon.identifier }, pokemon: pokemon)
            }

            for item in toUpdate {
                if let image = item.pokemon.image { item.object?.image = image }
                if let shiny = item.pokemon.shiny { item.object?.shiny = shiny }
            }

            // Add the new one
            let toInsert = splitFiltered.notMatching

            for item in toInsert {
                guard let entity = NSEntityDescription.entity(forEntityName: "Pokemon", in: context),
                      let object = NSManagedObject(entity: entity, insertInto: context) as? PokemonManaged
                        else { continue }

                object.identifier = item.identifier
                object.name = item.name
                object.imagePath = item.imagePath
                object.image = item.image
                object.shinyPath = item.shinyPath
                object.shiny = item.shiny
                object.pokedexPath = item.pokedexPath
            }

            // Save context
            saveChanges(on: context)
        }
    }

    func allPokemon() -> [Pokemon] {
        var results: [PokemonManaged] = []
        let context = backgroundContext
        context.performAndWait {
            let request = NSFetchRequest<PokemonManaged>(entityName: "Pokemon")
            let sort = NSSortDescriptor(key: "identifier", ascending: true)
            request.sortDescriptors = [sort]

            results = (try? context.fetch(request)) ?? []
        }
        return results.compactMap{ $0.toPokemon() }
    }

    func pokemon(identifier: Int) -> Pokemon? {
        var pokemon: Pokemon?
        let context = backgroundContext
        context.performAndWait {
            let request = NSFetchRequest<PokemonManaged>(entityName: "Pokemon")
            request.predicate = NSPredicate(format: "identifier = %i", identifier)
            let results = try? context.fetch(request)
            pokemon = results?.first?.toPokemon()
        }

        return pokemon
    }

    func save(entries: [Entry], to pokemon: Pokemon) {
        let context = backgroundContext
        context.performAndWait {
            var objects: [EntryManaged] = []
            for item in entries {
                guard let entity = NSEntityDescription.entity(forEntityName: "Entry", in: context),
                      let object = NSManagedObject(entity: entity, insertInto: context) as? EntryManaged
                        else { continue }

                object.flavorText = item.flavorText
                object.language = item.language
                object.version = item.version

                objects.append(object)
            }

            let request = NSFetchRequest<PokemonManaged>(entityName: "Pokemon")
            request.predicate = NSPredicate(format: "identifier = %i", pokemon.identifier)
            let results = try? context.fetch(request)
            let pokemon = results?.first

            pokemon?.entry = Set(objects)

            saveChanges(on: context)
        }
    }

    // MARK - Private methods
    private func saveChanges(on context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("""
                      💥 Save changes on context \(context.name ?? "Impossible to determine the name") has failed!
                      Error: \(error)
                      """)
            }
        }
    }
}

extension Collection {
    func separate(predicate: (Iterator.Element) -> Bool) -> (matching: [Iterator.Element], notMatching: [Iterator.Element]) {
        var groups: ([Iterator.Element],[Iterator.Element]) = ([],[])
        for element in self {
            if predicate(element) {
                groups.0.append(element)
            } else {
                groups.1.append(element)
            }
        }
        return groups
    }
}
