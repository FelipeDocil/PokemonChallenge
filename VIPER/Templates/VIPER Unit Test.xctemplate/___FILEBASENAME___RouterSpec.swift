// ___FILEHEADER___

@testable import ___PROJECTNAME___
import Nimble
import Quick

class ___VARIABLE_productName:identifier___RouterSpec: QuickSpec {
    override func spec() {
        describe("___VARIABLE_productName:identifier___RouterSpec") {
            it("configures the module") {
                let coordinator = Mock___VARIABLE_productName:identifier___Coordinator()

                let mockAnalytics = Mock___VARIABLE_productName:identifier___AnalyticsService()
                let mockServices = ___VARIABLE_productName:identifier___Services(analytics: mockAnalytics)

                let module = ___VARIABLE_productName:identifier___Router.build(from: coordinator, services: mockServices)
                
                let view = module as? ___VARIABLE_productName:identifier___View
                let presenter = view?.presenter as? ___VARIABLE_productName:identifier___Presenter
                let router = presenter?.router as? ___VARIABLE_productName:identifier___Router
                let interactor = presenter?.interactor as? ___VARIABLE_productName:identifier___Interactor

                expect(view).notTo(beNil())
                expect(presenter).notTo(beNil())
                expect(presenter?.view).notTo(beNil())
                expect(router).notTo(beNil())
                expect(router?.output).notTo(beNil())
                expect(router?.viewController).notTo(beNil())
                expect(interactor).notTo(beNil())
                expect(interactor?.output).notTo(beNil())
                expect(interactor?.services).notTo(beNil())
            }
        }
    }
}

class Mock___VARIABLE_productName:identifier___Coordinator: CoordinatorInput {
    var stubbedNavigationController: UINavigationController = UINavigationController()
    var navigationController: UINavigationController
    
    init() {
        navigationController = stubbedNavigationController
    }
       
    func buildRoot() -> UIViewController {
        fatalError("Dummy implementation")
    }
}
