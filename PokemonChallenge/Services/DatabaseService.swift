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
    func insertPokemon(pokemon: Pokemon) -> PokemonManaged?
    func fetchAllPokemon() -> [Pokemon]
    func pokemon(identifier: Int) -> Pokemon?
}

class DatabaseService: DatabaseServiceInput {
    var persistentContainer: NSPersistentContainer
    
    init(container: NSPersistentContainer) {
        self.persistentContainer = container
        self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    @discardableResult
    func insertPokemon(pokemon: Pokemon) -> PokemonManaged? {
        let context = persistentContainer.newBackgroundContext()
        
        if let cachedPokemon = fetch(identifier: pokemon.identifier) {
            return update(managedObject: cachedPokemon, with: pokemon)
        }
        
        guard
            let entity = NSEntityDescription.entity(forEntityName: "Pokemon", in: context),
            let pokemonManaged = NSManagedObject(entity: entity, insertInto: context) as? PokemonManaged
        else { return nil }
        
        pokemonManaged.identifier = pokemon.identifier
        pokemonManaged.name = pokemon.name
        pokemonManaged.imagePath = pokemon.imagePath
        pokemonManaged.image = pokemon.image
        pokemonManaged.shinyPath = pokemon.shinyPath
        pokemonManaged.shiny = pokemon.shiny
        pokemonManaged.pokedexPath = pokemon.pokedexPath
        
        do {
            try context.save()
        } catch {
            print("💥 Save \(pokemon.name) error \(error)")
        }
        
        return pokemonManaged
    }
    
    func fetchAllPokemon() -> [Pokemon] {
        let request = NSFetchRequest<PokemonManaged>(entityName: "Pokemon")
        let results = try? persistentContainer.viewContext.fetch(request)
        
        return results?.compactMap{ $0.toPokemon() } ?? []
    }
    
    func pokemon(identifier: Int) -> Pokemon? {
        let cached = fetch(identifier: identifier)
        
        return cached?.toPokemon()
    }
    
    private func fetch(identifier: Int) -> PokemonManaged? {
        let request = NSFetchRequest<PokemonManaged>(entityName: "Pokemon")
        request.predicate = NSPredicate(format: "identifier = %i", identifier)
        let results = try? persistentContainer.viewContext.fetch(request)
        
        return results?.count ?? 0 > 0 ? results?.first : nil
    }
    
    private func update(managedObject: PokemonManaged, with pokemon: Pokemon) -> PokemonManaged {
        if let image = pokemon.image {
            managedObject.image = image
        }
        
        if let shiny = pokemon.shiny {
            managedObject.shiny = shiny
        }
        
        do {
            try persistentContainer.viewContext.save()
        } catch {
            print("💥 Update \(pokemon.name) error \(error)")
        }
        
        return managedObject
    }
}
