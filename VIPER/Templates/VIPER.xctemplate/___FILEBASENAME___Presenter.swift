// ___FILEHEADER___

protocol ___VARIABLE_productName:identifier___PresenterInput: AnyObject {
    func viewIsReady()
}

class ___VARIABLE_productName:identifier___Presenter: ___VARIABLE_productName:identifier___PresenterInput, ___VARIABLE_productName:identifier___InteractorOutput, ___VARIABLE_productName:identifier___RouterOutput {
    weak var view: ___VARIABLE_productName:identifier___ViewInput?
    var interactor: ___VARIABLE_productName:identifier___InteractorInput
    var router: ___VARIABLE_productName:identifier___RouterInput

    init(interactor: ___VARIABLE_productName:identifier___InteractorInput, router: ___VARIABLE_productName:identifier___RouterInput) {
        self.interactor = interactor
        self.router = router
    }

    // MARK: ___VARIABLE_productName:identifier___PresenterInput

    func viewIsReady() {
        let viewData = ___VARIABLE_productName:identifier___ViewData()
        view?.setupInitialState(with: viewData)
    }
}
