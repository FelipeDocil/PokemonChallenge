//
//  Entry.swift
//  PokemonChallenge
//
//  Created by Felipe Docil on 05/12/2019.
//  Copyright © 2019 Felipe Docil. All rights reserved.
//

import Foundation

struct Entry: Codable {
    var flavorText: String
    var language: String
    var version: String
    
    enum CodingKeys: String, CodingKey {
        case flavorText = "flavor_text"
        case language
        case version
    }
    
    enum LanguageCodingKeys: String, CodingKey {
        case name
    }
    
    enum VersionCodingKeys: String, CodingKey {
        case name
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        flavorText = try container.decode(String.self, forKey: .flavorText)
        
        let language = try container.nestedContainer(keyedBy: LanguageCodingKeys.self, forKey: .language)
        self.language = try language.decode(String.self, forKey: .name)
        
        let version = try container.nestedContainer(keyedBy: VersionCodingKeys.self, forKey: .version)
        self.version = try version.decode(String.self, forKey: .name)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(flavorText, forKey: .flavorText)
        
        var language = container.nestedContainer(keyedBy: LanguageCodingKeys.self, forKey: .language)
        try language.encode(self.language, forKey: .name)
        
        var version = container.nestedContainer(keyedBy: VersionCodingKeys.self, forKey: .version)
        try version.encode(self.version, forKey: .name)
    }
}

extension Entry: Equatable {}
