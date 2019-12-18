// ___FILEHEADER___

@testable import ___PROJECTNAME___
import Nimble
import Quick
import SnapshotTesting
import SnapshotTesting_Nimble

class ___VARIABLE_productName:identifier___ViewSpec: QuickSpec {
    override func spec() {
        describe("___VARIABLE_productName:identifier___ViewSpec") {
            beforeSuite {
                // Snapshots must be compared using a simulator with the same OS, device as the simulator that originally took the reference
                self.verifyDevice()
            }
            it("snapshot the initial view") {
                let mockPresenter = Mock___VARIABLE_productName:identifier___Presenter()
                let view = ___VARIABLE_productName:identifier___View(presenter: mockPresenter)
                let viewData = ___VARIABLE_productName:identifier___ViewData()

                view.setupInitialState(with: viewData)

                let navigationController = UINavigationController(rootViewController: view)

                record = false
                expect(navigationController).to(haveValidSnapshot(as: .image(on: .iPhoneSe), named: "iPhoneSE"))
                expect(navigationController).to(haveValidSnapshot(as: .image(on: .iPhone8), named: "iPhone8"))
                expect(navigationController).to(haveValidSnapshot(as: .image(on: .iPhone8Plus), named: "iPhone8Plus"))
                expect(navigationController).to(haveValidSnapshot(as: .image(on: .iPhone11), named: "iPhone11"))
                expect(navigationController).to(haveValidSnapshot(as: .image(on: .iPhone11Pro), named: "iPhone11Pro"))
            }
        }
    }
}

class Mock___VARIABLE_productName:identifier___Presenter: ___VARIABLE_productName:identifier___PresenterInput {
    var invokedViewIsReady = false
    var invokedViewIsReadyCount = 0

    func viewIsReady() {
        invokedViewIsReady = true
        invokedViewIsReadyCount += 1
    }
}