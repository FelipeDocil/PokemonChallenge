// ___FILEHEADER___

import UIKit

class ___VARIABLE_productName:identifier___Services {}

protocol ___VARIABLE_productName:identifier___RouterOutput: AnyObject {}

protocol ___VARIABLE_productName:identifier___RouterInput: AnyObject {
    static func build(from coordinator: CoordinatorInput, services: ___VARIABLE_productName:identifier___Services) -> UIViewController
}

class ___VARIABLE_productName:identifier___Router: ___VARIABLE_productName:identifier___RouterInput {
    weak var viewController: UIViewController?
    weak var output: ___VARIABLE_productName:identifier___RouterOutput?

    struct Dependencies {
        weak var coordinator: CoordinatorInput?
        weak var services: ___VARIABLE_productName:identifier___Services?
    }

    private var dependencies: Dependencies

    private init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    // MARK: ___VARIABLE_productName:identifier___RouterInput

    static func build(from coordinator: CoordinatorInput, services: ___VARIABLE_productName:identifier___Services) -> UIViewController {
        let dependencies = Dependencies(coordinator: coordinator, services: services)

        // VIPER classes

        let router = ___VARIABLE_productName:identifier___Router(dependencies: dependencies)
        let interactor = ___VARIABLE_productName:identifier___Interactor()
        let presenter = ___VARIABLE_productName:identifier___Presenter(interactor: interactor, router: router)
        let view = ___VARIABLE_productName:identifier___View(presenter: presenter)
        
        router.output = presenter
        router.viewController = view
        interactor.output = presenter
        interactor.services = dependencies.services
        presenter.view = view

        return view
    }
}
