//
//  Pokemon.swift
//  PokemonChallenge
//
//  Created by Felipe Docil on 06/02/2020.
//  Copyright © 2020 Felipe Docil. All rights reserved.
//

import Foundation

struct Pokemon: Identifiable {
    var id = UUID()
    var number: Int
    var name: String
    var imagePath: URL
    var image: Data?
    var types: [String]
    var abilities: [Ability]
}

struct Ability {
    var name: String
    var isHidden: Bool
}
