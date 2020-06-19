//
//  PokemonRealm.swift
//  PokemonChallenge
//
//  Created by Felipe Docil on 20/12/2019.
//  Copyright © 2019 Felipe Docil. All rights reserved.
//

import RealmSwift

class PokemonRealm: Object {
    @objc dynamic var identifier: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var pokedexPath: String = ""
    @objc dynamic var imagePath: String = ""
    @objc dynamic var shinyPath: String = ""
    @objc dynamic var image: Data?
    @objc dynamic var shiny: Data?
//    @objc dynamic var entry: Set<EntryManaged>?
    
    func fill(with pokemon: Pokemon) {
        identifier = pokemon.identifier
        name = pokemon.name
        pokedexPath = pokemon.pokedexPath.absoluteString
        imagePath = pokemon.imagePath.absoluteString
        shinyPath = pokemon.shinyPath.absoluteString
        image = pokemon.image
        shiny = pokemon.shiny
    }
    
    /**required init() {
        fatalError("init() has not been implemented")
    }*/
    
    override class func primaryKey() -> String? {
        return "identifier"
    }
}

extension PokemonRealm {
    func toPokemon() -> Pokemon? {
        let jsonEncoder = JSONEncoder()
        guard let pokemonData = try? jsonEncoder.encode(self) else { return nil }
        
        let jsonDecoder = JSONDecoder()
        var pokemon = try? jsonDecoder.decode(Pokemon.self, from: pokemonData)
        pokemon?.image = self.image
        pokemon?.shiny = self.shiny
        
//        if let entryData = try? jsonEncoder.encode(entry) {
//            let entry = try? jsonDecoder.decode([Entry].self, from: entryData)
//            pokemon?.entry = entry ?? []
//        }
        
        return pokemon
    }
}

extension PokemonRealm: Encodable {
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
