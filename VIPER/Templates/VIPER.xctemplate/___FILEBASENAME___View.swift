// ___FILEHEADER___

import UIKit

private struct Constant {
    struct AccessibilityIdentifier {
        static let ___VARIABLE_productName:identifier___View = "___VARIABLE_productName:identifier____view"
    }
}

struct ___VARIABLE_productName:identifier___ViewData {}

extension ___VARIABLE_productName:identifier___ViewData: Equatable {
    public static func ==(lhs: ___VARIABLE_productName:identifier___ViewData, rhs: ___VARIABLE_productName:identifier___ViewData) -> Bool {
        return true
    }
}

protocol ___VARIABLE_productName:identifier___ViewInput: AnyObject {
    func setupInitialState(with viewData: ___VARIABLE_productName:identifier___ViewData)
}

class ___VARIABLE_productName:identifier___View: UIViewController, ___VARIABLE_productName:identifier___ViewInput {
    var presenter: ___VARIABLE_productName:identifier___PresenterInput

    init(presenter: ___VARIABLE_productName:identifier___PresenterInput) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.accessibilityIdentifier = Constant.AccessibilityIdentifier.___VARIABLE_productName:identifier___View
        setupLayout()

        presenter.viewIsReady()
    }

    // MARK: ___VARIABLE_productName:identifier___ViewInput
    func setupInitialState(with viewData: ___VARIABLE_productName:identifier___ViewData) {}

    // MARK: Layout
    private func setupLayout() {}
}
