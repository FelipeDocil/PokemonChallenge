//
//  UITestArguments.swift
//  PokemonChallenge
//
//  Created by Felipe Docil on 23/11/2019.
//  Copyright © 2019 Felipe Docil. All rights reserved.
//

import Foundation

enum Arguments: String {
    case uiTest
    
    enum Initial: String {
        case list
    }
    
    enum Networking: String {
        case noNetwork
        case singlePage
        case multiplePages
        case successPokemon
        case successEntry
    }
    
    enum Persistence: String {
        case empty
        case cached
        case caches
    }
}
