// 
//  PokemonDetailRouter.swift
//  PokemonChallenge
//
//  Created by Felipe Docil on 04/12/2019.
//  Copyright © 2019 Felipe Docil. All rights reserved.
//

import UIKit

class PokemonDetailServices {
    var networking: NetworkingServiceInput, database: DatabaseServiceInput

    init(networking: NetworkingServiceInput, database: DatabaseServiceInput) {
        self.networking = networking
        self.database = database
    }
}

protocol PokemonDetailRouterOutput: AnyObject {}

protocol PokemonDetailRouterInput: AnyObject {
    static func build(from coordinator: CoordinatorInput, services: PokemonDetailServices, identifier: Int, isShiny: Bool) -> UIViewController
}

class PokemonDetailRouter: PokemonDetailRouterInput {
    weak var viewController: UIViewController?
    weak var output: PokemonDetailRouterOutput?

    struct Dependencies {
        weak var coordinator: CoordinatorInput?
        weak var services: PokemonDetailServices?
    }

    private var dependencies: Dependencies

    private init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    // MARK: PokemonDetailRouterInput

    static func build(from coordinator: CoordinatorInput, services: PokemonDetailServices, identifier: Int, isShiny: Bool) -> UIViewController {
        let dependencies = Dependencies(coordinator: coordinator, services: services)

        // VIPER classes

        let router = PokemonDetailRouter(dependencies: dependencies)
        let interactor = PokemonDetailInteractor()
        let presenter = PokemonDetailPresenter(interactor: interactor, router: router, identifier: identifier, isShiny: isShiny)
        let view = PokemonDetailView(presenter: presenter)
        
        router.output = presenter
        router.viewController = view
        interactor.output = presenter
        interactor.services = dependencies.services
        presenter.view = view

        return view
    }
}
