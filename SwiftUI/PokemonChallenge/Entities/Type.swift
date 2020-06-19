//
//  Type.swift
//  PokemonChallenge
//
//  Created by Felipe Docil on 07/02/2020.
//  Copyright © 2020 Felipe Docil. All rights reserved.
//

import SwiftUI

enum Type: String, CaseIterable, Identifiable {
    case normal
    case fire
    case fighting
    case water
    case flying
    case grass
    case poison
    case electric
    case ground
    case psychic
    case rock
    case ice
    case bug
    case dragon
    case ghost
    case dark
    case steel
    case fairy
    
    var id: String { rawValue }
    
    var color: some View {
        switch self {
        case .normal: return Color.init(red: 146/255, green: 146/255, blue: 146/255)
        case .fire: return Color.init(red: 253/255, green: 157/255, blue: 93/255)
        case .fighting: return Color.init(red: 204/255, green: 68/255, blue: 108/255)
        case .water: return Color.init(red: 83/255, green: 146/255, blue: 212/255)
        case .flying: return Color.init(red: 144/255, green: 170/255, blue: 220/255)
        case .grass: return Color.init(red: 102/255, green: 187/255, blue: 95/255)
        case .poison: return Color.init(red: 169/255, green: 110/255, blue: 198/255)
        case .electric: return Color.init(red: 243/255, green: 208/255, blue: 76/255)
        case .ground: return Color.init(red: 215/255, green: 120/255, blue: 75/255)
        case .psychic: return Color.init(red: 248/255, green: 114/255, blue: 124/255)
        case .rock: return Color.init(red: 197/255, green: 183/255, blue: 142/255)
        case .ice: return Color.init(red: 119/255, green: 206/255, blue: 192/255)
        case .bug: return Color.init(red: 146/255, green: 192/255, blue: 60/255)
        case .dragon: return Color.init(red: 23/255, green: 111/255, blue: 193/255)
        case .ghost: return Color.init(red: 83/255, green: 107/255, blue: 171/255)
        case .dark: return Color.init(red: 90/255, green: 85/255, blue: 101/255)
        case .steel: return Color.init(red: 92/255, green: 142/255, blue: 161/255)
        case .fairy: return Color.init(red: 235/255, green: 146/255, blue: 228/255)
        }
    }
    
    var effectiveness: [(type: Type, value: Double)] {
        switch self {
        case .normal: return [(type: .fighting, value: 2),
                              (type: .ghost, value: 0)]
        
        case .fire: return [(type: .ground, value: 2),
                            (type: .rock, value: 2),
                            (type: .water, value: 2),
                            (type: .bug, value: 0.5),
                            (type: .steel, value: 0.5),
                            (type: .fire, value: 0.5),
                            (type: .grass, value: 0.5),
                            (type: .ice, value: 0.5),
                            (type: .fairy, value: 0.5)]
        
        case .fighting: return [(type: .flying, value: 2),
                                (type: .psychic, value: 2),
                                (type: .fairy, value: 2),
                                (type: .rock, value: 0.5),
                                (type: .bug, value: 0.5),
                                (type: .dark, value: 0.5)]
        
        case .water: return [(type: .grass, value: 2),
                             (type: .electric, value: 2),
                             (type: .steel, value: 0.5),
                             (type: .fire, value: 0.5),
                             (type: .water, value: 0.5),
                             (type: .ice, value: 0.5)]
        
        case .flying: return [(type: .rock, value: 2),
                              (type: .electric, value: 2),
                              (type: .ice, value: 2),
                              (type: .ground, value: 0),
                              (type: .fighting, value: 0.5),
                              (type: .bug, value: 0.5),
                              (type: .grass, value: 0.5)]
            
        case .grass: return [(type: .flying, value: 2),
                             (type: .poison, value: 2),
                             (type: .bug, value: 2),
                             (type: .fire, value: 2),
                             (type: .ice, value: 2),
                             (type: .ground, value: 0.5),
                             (type: .water, value: 0.5),
                             (type: .grass, value: 0.5),
                             (type: .electric, value: 0.5)]
           
        case .poison: return [(type: .ground, value: 2),
                              (type: .psychic, value: 2),
                              (type: .bug, value: 0.5),
                              (type: .fighting, value: 0.5),
                              (type: .poison, value: 0.5),
                              (type: .grass, value: 0.5)]
            
        case .electric: return [(type: .ground, value: 2),
                                (type: .electric, value: 0.5),
                                (type: .flying, value: 0.5),
                                (type: .steel, value: 0.5)]
            
        case .ground: return [(type: .grass, value: 2),
                              (type: .ice, value: 2),
                              (type: .water, value: 2),
                              (type: .electric, value: 0),
                              (type: .poison, value: 0.5),
                              (type: .rock, value: 0.5)]
            
        case .psychic: return [(type: .bug, value: 2),
                               (type: .dark, value: 2),
                               (type: .ghost, value: 2),
                               (type: .fighting, value: 0.5),
                               (type: .psychic, value: 0.5)]
            
        case .rock: return [(type: .fighting, value: 2),
                            (type: .grass, value: 2),
                            (type: .ground, value: 2),
                            (type: .water, value: 2),
                            (type: .fire, value: 0.5),
                            (type: .flying, value: 0.5),
                            (type: .normal, value: 0.5),
                            (type: .poison, value: 0.5)]
            
        case .ice: return [(type: .fighting, value: 2),
                           (type: .fire, value: 2),
                           (type: .rock, value: 2),
                           (type: .ice, value: 0.5)]
            
        case .bug: return [(type: .fire, value: 2),
                           (type: .flying, value: 2),
                           (type: .rock, value: 2),
                           (type: .fighting, value: 0.5),
                           (type: .grass, value: 0.5),
                           (type: .ground, value: 0.5)]
            
        case .dragon: return [(type: .dragon, value: 2),
                              (type: .ice, value: 2),
                              (type: .fire, value: 0.5),
                              (type: .electric, value: 0.5),
                              (type: .grass, value: 0.5),
                              (type: .water, value: 0.5)]
            
        case .ghost: return [(type: .ghost, value: 2),
                             (type: .dark, value: 2),
                             (type: .normal, value: 0),
                             (type: .fighting, value: 0),
                             (type: .bug, value: 0.5),
                             (type: .poison, value: 0.5)]
            
        case .dark: return [(type: .bug, value: 2),
                            (type: .fighting, value: 2),
                            (type: .psychic, value: 0),
                            (type: .dark, value: 0.5),
                            (type: .ghost, value: 0.5)]
            
        case .steel: return [(type: .fighting, value: 2),
                             (type: .fire, value: 2),
                             (type: .ground, value: 2),
                             (type: .poison, value: 0),
                             (type: .bug, value: 0.5),
                             (type: .dark, value: 0.5),
                             (type: .dragon, value: 0.5),
                             (type: .flying, value: 0.5),
                             (type: .ghost, value: 0.5),
                             (type: .grass, value: 0.5),
                             (type: .ice, value: 0.5),
                             (type: .normal, value: 0.5),
                             (type: .psychic, value: 0.5),
                             (type: .rock, value: 0.5),
                             (type: .steel, value: 0.5)]
            
        case .fairy: return [(type: .poison, value: 2),
                             (type: .steel, value: 2),
                             (type: .dragon, value: 0),
                             (type: .bug, value: 0.5),
                             (type: .dark, value: 0.5),
                             (type: .fighting, value: 0.5)]
        }
    }
}
