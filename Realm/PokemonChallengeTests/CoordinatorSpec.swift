//
//  CoordinatorSpec.swift
//  PokemonChallengeTests
//
//  Created by Felipe Docil on 24/11/2019.
//  Copyright © 2019 Felipe Docil. All rights reserved.
//

@testable import PokemonChallenge
import Nimble
import Quick
import CoreData

class CoordinatorSpec: QuickSpec {
    lazy var managedObjectModel: NSManagedObjectModel = {
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle(for: type(of: self))] )!
        return managedObjectModel
    }()
    
    lazy var mockPersistantContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "PokemonChallenge", managedObjectModel: self.managedObjectModel)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false // Make it simpler in test env
        
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { (description, error) in
            // Check if the data store is in memory
            precondition( description.type == NSInMemoryStoreType )
            
            // Check if creating container wrong
            if let error = error {
                fatalError("Create an in-mem coordinator failed \(error)")
            }
        }
        return container
    }()
    
    override func spec() {
        describe("CoordinatorSpec") {
            it("configures root controller") {
                let coordinator = Coordinator()
                
                let root = coordinator.buildRoot()
                let navigationController = UINavigationController(rootViewController: root)
                
                expect(navigationController.topViewController).to(beAKindOf(PokemonListView.self))
                expect(navigationController.viewControllers.count) == 1
            }
            
            it("present detail view") {
                let coordinator = Coordinator()
                
                let navigationController = UINavigationController()
                
                coordinator.presentDetail(in: navigationController, with: 1, isShiny: false)
                
                expect(navigationController.topViewController).toEventually(beAKindOf(PokemonDetailView.self))
            }
        }
    }
}
