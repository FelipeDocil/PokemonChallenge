//
//  EntryManaged.swift
//  PokemonChallenge
//
//  Created by Felipe Docil on 15/12/2019.
//  Copyright © 2019 Felipe Docil. All rights reserved.
//

import Foundation
import CoreData

class EntryManaged: NSManagedObject {
    @NSManaged var flavorText: String
    @NSManaged var language: String
    @NSManaged var version: String
}

extension Entry {
    func toManaged(in context: NSManagedObjectContext) -> EntryManaged? {
        guard
            let entity = NSEntityDescription.entity(forEntityName: "Entry", in: context),
            let managed = NSManagedObject(entity: entity, insertInto: context) as? EntryManaged
        else { return nil }
        
        managed.flavorText = self.flavorText
        managed.language = self.language
        managed.version = self.version
        
        return managed
    }
}

extension EntryManaged: Encodable {
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
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(flavorText, forKey: .flavorText)
        
        var language = container.nestedContainer(keyedBy: LanguageCodingKeys.self, forKey: .language)
        try language.encode(self.language, forKey: .name)
        
        var version = container.nestedContainer(keyedBy: VersionCodingKeys.self, forKey: .version)
        try version.encode(self.version, forKey: .name)
    }
}
