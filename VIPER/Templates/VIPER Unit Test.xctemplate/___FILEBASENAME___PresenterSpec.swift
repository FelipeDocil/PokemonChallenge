// ___FILEHEADER___

@testable import ___PROJECTNAME___
import Nimble
import Quick

class ___VARIABLE_productName:identifier___PresenterSpec: QuickSpec {
    override func spec() {
        describe("___VARIABLE_productName:identifier___PresenterSpec") {
            it("configures view") {
                let mockView = Mock___VARIABLE_productName:identifier___View()
                let mockRouter = Mock___VARIABLE_productName:identifier___Router()
                let mockInteractor = Mock___VARIABLE_productName:identifier___Interactor()
                let presenter = ___VARIABLE_productName:identifier___Presenter(interactor: mockInteractor, router: mockRouter)
                presenter.view = mockView
                
                let expectedViewData = ___VARIABLE_productName:identifier___ViewData()

                presenter.viewIsReady()

                expect(mockView.invokedSetupInitialStateParameters?.viewData) == expectedViewData
            }
        }
    }
}

class Mock___VARIABLE_productName:identifier___Interactor: ___VARIABLE_productName:identifier___InteractorInput {}

class Mock___VARIABLE_productName:identifier___Router: ___VARIABLE_productName:identifier___RouterInput {
    static func build(from coordinator: CoordinatorInput, services: ___VARIABLE_productName:identifier___Services) -> UIViewController {
        fatalError("Dummy implementation")
    }
}

class Mock___VARIABLE_productName:identifier___View: ___VARIABLE_productName:identifier___ViewInput {
    var invokedSetupInitialState = false
    var invokedSetupInitialStateCount = 0
    var invokedSetupInitialStateParameters: (viewData: ___VARIABLE_productName:identifier___ViewData, Void)?
    var invokedSetupInitialStateParametersList = [(viewData: ___VARIABLE_productName:identifier___ViewData, Void)]()

    func setupInitialState(with viewData: ___VARIABLE_productName:identifier___ViewData) {
        invokedSetupInitialState = true
        invokedSetupInitialStateCount += 1
        invokedSetupInitialStateParameters = (viewData, ())
        invokedSetupInitialStateParametersList.append((viewData, ()))
    }
}
