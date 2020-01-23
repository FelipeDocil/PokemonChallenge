//
//  Pokemon.swift
//  PokemonChallenge
//
//  Created by Felipe Docil on 23/11/2019.
//  Copyright © 2019 Felipe Docil. All rights reserved.
//

import Foundation

struct Pokemon: Codable {
    var identifier: Int
    var name: String
    var pokedexPath: URL
    var imagePath: URL
    var shinyPath: URL
    var image: Data?
    var shiny: Data?
    var entry: [Entry] = []

    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case name
        case species
        case pokedex = "url"
        case sprites
        case imagePath = "front_default"
        case shinyPath = "front_shiny"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        identifier = try container.decode(Int.self, forKey: .identifier)
        name = try container.decode(String.self, forKey: .name)

        let species = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .species)
        pokedexPath = try species.decode(URL.self, forKey: .pokedex)

        let sprites = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .sprites)
        imagePath = try sprites.decode(URL.self, forKey: .imagePath)
        shinyPath = try sprites.decode(URL.self, forKey: .shinyPath)
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

extension Pokemon: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.identifier)
    }
}

extension Pokemon: Equatable {
    static func == (lhs: Pokemon, rhs: Pokemon) -> Bool {
        lhs.identifier == rhs.identifier &&
        lhs.image == rhs.image &&
        lhs.shiny == rhs.shiny
    }
}
