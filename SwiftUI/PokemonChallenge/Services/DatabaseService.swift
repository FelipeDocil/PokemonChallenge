//
//  DatabaseService.swift
//  PokemonChallenge
//
//  Created by Felipe Docil on 06/02/2020.
//  Copyright © 2020 Felipe Docil. All rights reserved.
//

import Foundation
import Combine
import CoreData

protocol DatabaseServiceInput {
    func allPokemon() -> [Pokemon]
}

class DatabaseService: DatabaseServiceInput {
    var persistentContainer: NSPersistentContainer

    lazy var backgroundContext: NSManagedObjectContext = {
        let tmpContext = persistentContainer.newBackgroundContext()
        tmpContext.automaticallyMergesChangesFromParent = true
        tmpContext.name = "background context"

        return tmpContext
    }()

    init(container: NSPersistentContainer) {
        self.persistentContainer = container
        self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        
        initDatabase()
    }
    
    func allPokemon() -> [Pokemon] {
        return []
    }
    
    // MARK: Private methods
    
    func initDatabase() {
        
    }
}
