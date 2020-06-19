//
//  Coordinator.swift
//  PokemonChallenge
//
//  Created by Felipe Docil on 06/02/2020.
//  Copyright © 2020 Felipe Docil. All rights reserved.
//

import SwiftUI
import CoreData

class Coordinator {
    
    // Services
    
    lazy var databaseService: DatabaseServiceInput = DatabaseService(container: container)

    var container: NSPersistentContainer

    init(container: NSPersistentContainer) {
        self.container = container
    }

    func buildRoot() -> some View {
        return buildTabbar()
    }
}

// MARK: Builder

extension Coordinator {
    func buildTabbar() -> some View {
        let list = buildList() as! ListView
        let effectiveness = buildEffectiveness() as! EffectivenessView
        let ev = buildEVTraining() as! EVView
        
        let services = TabbarServices()
        let modules = TabbarModules(list: list.viewModel, effectiveness: effectiveness.viewModel, evTraining: ev.viewModel)
        let viewModel = TabbarViewModel(coordinator: self, services: services, modules: modules)
        let view = TabbarView(viewModel: viewModel)
        
        return view
    }
    
    func buildList() -> some View {
        let services = ListServices(databaseService: databaseService)
        let viewModel = ListViewModel(coordinator: self, services: services)
        let view = ListView(viewModel: viewModel)

        return view
    }
    
    func buildEffectiveness() -> some View {
        let services = EffectivenessServices()
        let viewModel = EffectivenessViewModel(coordinator: self, services: services)
        let view = EffectivenessView(viewModel: viewModel)

        return view
    }
    
    func buildEVTraining() -> some View {
        let services = EVServices()
        let viewModel = EVViewModel(coordinator: self, services: services)
        let view = EVView(viewModel: viewModel)
        
        return view
    }
}

#if DEBUG
// MARK: Preview

extension Coordinator {
    static var mockPersistentContainer: NSPersistentContainer {
        let container = NSPersistentContainer(name: "PokemonChallenge")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false

        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { description, error in
            precondition(description.type == NSInMemoryStoreType)

            if let error = error {
                fatalError("Create an in-mem coordinator failed \(error)")
            }
        }

        return container
    }
}
#endif
