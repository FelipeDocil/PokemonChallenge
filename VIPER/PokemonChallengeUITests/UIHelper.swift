//
//  UIHelper.swift
//  PokemonChallengeUITests
//
//  Created by Felipe Docil on 25/11/2019.
//  Copyright © 2019 Felipe Docil. All rights reserved.
//

import XCTest

extension XCTestCase {
    func launchApp(arguments: [String] = []) {
        let app = XCUIApplication()
        app.launchEnvironment[Arguments.uiTest.rawValue] = "true"
        
        app.launchArguments.append(contentsOf: arguments)
        app.launch()
    }
}

extension XCUIElement {
    func scrollToElement(element: XCUIElement, scrollLimit: Int = 3) {
        var scrolls = 0
        while !element.exists && scrolls <= scrollLimit  {
            swipeUp()
            scrolls = scrolls + 1
        }
    }

    func visible() -> Bool {
        guard self.exists && !self.frame.isEmpty else { return false }
        return XCUIApplication().windows.element(boundBy: 0).frame.contains(self.frame)
    }
    
    func forceTap() {
        if isHittable {
            tap()
        } else {
            let coordinate: XCUICoordinate = self.coordinate(withNormalizedOffset: CGVector(dx: 0.0, dy: 0.0))
            coordinate.tap()
        }
    }
}
