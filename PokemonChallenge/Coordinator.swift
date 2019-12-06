//
//  Coordinator.swift
//  PokemonChallenge
//
//  Created by Felipe Docil on 23/11/2019.
//  Copyright © 2019 Felipe Docil. All rights reserved.
//

import UIKit
import CoreData

protocol CoordinatorInput: AnyObject {
    func buildRoot() -> UIViewController
    func presentDetail(in navigationController: UINavigationController?, with identifier: Int, isShiny: Bool)
}

protocol CoordinatorBuilder {
    var networkingService: NetworkingServiceInput { get }
    var databaseService: DatabaseServiceInput { get }
}

class Coordinator: CoordinatorInput, CoordinatorBuilder {
    var persistentContainer: NSPersistentContainer
    
    lazy var networkingService: NetworkingServiceInput = NetworkingService()
    lazy var databaseService: DatabaseServiceInput = DatabaseService(container: persistentContainer)
    
    init(container: NSPersistentContainer) {
        self.persistentContainer = container
    }
    
    func buildRoot() -> UIViewController {
        return buildPokemonList()
    }
    
    func presentDetail(in navigationController: UINavigationController?, with identifier: Int, isShiny: Bool) {
        let detail = buildPokemonDetail(for: identifier, isShiny: isShiny)
        
        DispatchQueue.main.async {
            navigationController?.pushViewController(detail, animated: true)
        }
    }
}

// - MARK: Builder

extension CoordinatorBuilder where Self: CoordinatorInput {
    func buildPokemonList() -> UIViewController {
        let services = PokemonListServices(networking: networkingService, database: databaseService)
        let list = PokemonListRouter.build(from: self, services: services)
        
        return list
    }
    
    func buildPokemonDetail(for identifier: Int, isShiny: Bool) -> UIViewController {
        let services = PokemonDetailServices(networking: networkingService, database: databaseService)
        let detail = PokemonDetailRouter.build(from: self, services: services, identifier: identifier, isShiny: isShiny)
        
        return detail
    }
}
