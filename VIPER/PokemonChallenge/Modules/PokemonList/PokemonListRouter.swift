// 
//  PokemonListRouter.swift
//  PokemonChallenge
//
//  Created by Felipe Docil on 23/11/2019.
//  Copyright © 2019 Felipe Docil. All rights reserved.
//

import UIKit

class PokemonListServices {
    var networking: NetworkingServiceInput, database: DatabaseServiceInput

    init(networking: NetworkingServiceInput, database: DatabaseServiceInput) {
        self.networking = networking
        self.database = database
    }
}

protocol PokemonListRouterOutput: AnyObject {}

protocol PokemonListRouterInput: AnyObject {
    static func build(from coordinator: CoordinatorInput, services: PokemonListServices) -> UIViewController
    func presentDetail(for identifier: Int, isShiny: Bool)
}

class PokemonListRouter: PokemonListRouterInput {
    weak var viewController: UIViewController?
    weak var output: PokemonListRouterOutput?

    struct Dependencies {
        weak var coordinator: CoordinatorInput?
        weak var services: PokemonListServices?
    }

    private var dependencies: Dependencies

    private init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    // MARK: PokemonListRouterInput

    static func build(from coordinator: CoordinatorInput, services: PokemonListServices) -> UIViewController {
        let dependencies = Dependencies(coordinator: coordinator, services: services)

        // VIPER classes

        let router = PokemonListRouter(dependencies: dependencies)
        let interactor = PokemonListInteractor()
        let presenter = PokemonListPresenter(interactor: interactor, router: router)
        let view = PokemonListView(presenter: presenter)
        
        router.output = presenter
        router.viewController = view
        interactor.output = presenter
        interactor.services = dependencies.services
        presenter.view = view

        return view
    }
    
    func presentDetail(for identifier: Int, isShiny: Bool) {
        dependencies.coordinator?.presentDetail(in: viewController?.navigationController, with: identifier, isShiny: isShiny)
    }
}
