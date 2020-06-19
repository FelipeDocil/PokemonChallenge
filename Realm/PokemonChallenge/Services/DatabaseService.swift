//
//  DatabaseService.swift
//  PokemonChallenge
//
//  Created by Felipe Docil on 20/12/2019.
//  Copyright © 2019 Felipe Docil. All rights reserved.
//

import Foundation
import RealmSwift

enum DatabaseType {
    case inDisk
    case inMemory
}

protocol DatabaseServiceInput {
    @discardableResult
    func allPokemon() -> [Pokemon]
    func pokemon(identifier: Int) -> Pokemon?
    func save(pokemon: [Pokemon])
    func save(entries: [Entry], to pokemon: Pokemon)
}

class DatabaseService: DatabaseServiceInput {
    var type: DatabaseType

    init(type: DatabaseType = .inDisk) {
        self.type = type
    }

    @discardableResult
    func insertPokemon(pokemon: Pokemon) -> PokemonRealm {
        if let cachedPokemon = fetch(identifier: pokemon.identifier) {
            return update(realmObject: cachedPokemon, with: pokemon)
        }

        let pokemonRealm = PokemonRealm()
        pokemonRealm.fill(with: pokemon)

        do {
            let realm = try createRealmInstance()
            try realm.write {
                realm.add(pokemonRealm, update: .modified)
            }
        } catch {
            print("💥 Save \(pokemon.name) error \(error)")
        }

        return pokemonRealm
    }

    func fetchAllPokemon() -> [Pokemon] {
        let realm = try! createRealmInstance()
        let pokemon = realm.objects(PokemonRealm.self).compactMap({ $0.toPokemon() })

        return Array(pokemon)
    }

    func pokemon(identifier: Int) -> Pokemon? {
        let cached = fetch(identifier: identifier)

        return cached?.toPokemon()
    }

    // MARK: Private methods

    private func createRealmInstance() throws -> Realm {
        switch type {
        case .inDisk:
            return try Realm()
        case .inMemory:
            return try Realm(configuration: .init(inMemoryIdentifier: "realm_in_memmory"))
        }
    }

    private func fetch(identifier: Int) -> PokemonRealm? {
        let realm = try! createRealmInstance()
        let cached = realm.object(ofType: PokemonRealm.self, forPrimaryKey: identifier)

        return cached
    }

    private func update(realmObject: PokemonRealm, with pokemon: Pokemon) -> PokemonRealm {
        do {
            let realm = try createRealmInstance()
            try realm.write {
                if let image = pokemon.image {
                    realmObject.image = image
                }

                if let shiny = pokemon.shiny {
                    realmObject.shiny = shiny
                }

                realm.add(realmObject, update: .modified)
            }
        } catch {
            print("💥 Update \(pokemon.name) error \(error)")
        }

        return realmObject
    }
}
