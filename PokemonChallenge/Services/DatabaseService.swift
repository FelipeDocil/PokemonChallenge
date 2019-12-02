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
        if let cachedPokemon = fetch(pokemon: pokemon) {
            return cachedPokemon
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
            print("💥 Save error \(error)")
        }
        
        return pokemonManaged
    }
    
    func fetchAllPokemon() -> [Pokemon] {
        let request = NSFetchRequest<PokemonManaged>(entityName: "Pokemon")
        let results = try? persistentContainer.viewContext.fetch(request)
        
        return results?.compactMap{ $0.toPokemon() } ?? []
    }
    
    private func fetch(pokemon: Pokemon) -> PokemonManaged? {
        let request = NSFetchRequest<PokemonManaged>(entityName: "Pokemon")
        request.predicate = NSPredicate(format: "identifier = %i", pokemon.identifier)
        let results = try? persistentContainer.viewContext.fetch(request)
        
        return results?.count ?? 0 > 0 ? results?.first : nil
    }
}
