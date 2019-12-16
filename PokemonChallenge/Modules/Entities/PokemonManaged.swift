//
//  PokemonManaged.swift
//  PokemonChallenge
//
//  Created by Felipe Docil on 23/11/2019.
//  Copyright © 2019 Felipe Docil. All rights reserved.
//

import Foundation
import CoreData

class PokemonManaged: NSManagedObject {
    @NSManaged var identifier: Int
    @NSManaged var name: String
    @NSManaged var pokedexPath: URL
    @NSManaged var imagePath: URL
    @NSManaged var shinyPath: URL
    @NSManaged var image: Data?
    @NSManaged var shiny: Data?
    @NSManaged var entry: Set<EntryManaged>?
}

extension PokemonManaged {
    func toPokemon() -> Pokemon? {
        let jsonEncoder = JSONEncoder()
        guard let pokemonData = try? jsonEncoder.encode(self) else { return nil }
        
        let jsonDecoder = JSONDecoder()
        var pokemon = try? jsonDecoder.decode(Pokemon.self, from: pokemonData)
        pokemon?.image = self.image
        pokemon?.shiny = self.shiny
        
        if let entryData = try? jsonEncoder.encode(entry) {
            let entry = try? jsonDecoder.decode([Entry].self, from: entryData)
            pokemon?.entry = entry ?? []
        }
        
        return pokemon
    }
}

extension PokemonManaged: Encodable {
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case name
        case species
        case pokedex = "url"
        case sprites
        case imagePath = "front_default"
        case shinyPath = "front_shiny"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(identifier, forKey: .identifier)
        try container.encode(name, forKey: .name)
        
        var species = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .species)
        try species.encode(pokedexPath, forKey: .pokedex)
        
        var sprites = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .sprites)
        try sprites.encode(imagePath, forKey: .imagePath)
        try sprites.encode(shinyPath, forKey: .shinyPath)
    }
}
