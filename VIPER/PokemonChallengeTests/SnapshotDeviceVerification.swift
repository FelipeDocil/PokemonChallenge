//
//  SnapshotDeviceVerification.swift
//  PokemonChallengeTests
//
//  Created by Felipe Docil on 24/11/2019.
//  Copyright © 2019 Felipe Docil. All rights reserved.
//

import XCTest
import SnapshotTesting

extension XCTestCase {
    func verifyDevice(file: StaticString = #file, line: UInt = #line) {
        let iPhone11 = "iPhone12,1"
        
        guard ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] == iPhone11 else {
            XCTFail("Please run your View tests in a iPhone 11 device simulator", file: file, line: line)
            return
        }
        
        let iOS13 = OperatingSystemVersion(majorVersion: 13, minorVersion: 0, patchVersion: 0)
        guard ProcessInfo().isOperatingSystemAtLeast(iOS13) else {
            XCTFail("Please run your View tests in a iOS 13 device simulator", file: file, line: line)
            return
        }
    }
}

extension ViewImageConfig {
    /**
     iPhone 11 has the same configurations as the iPhone Xr
     iPhone 11 Pro has the same configurations as the iPhone X
     Create both anyway to be more clear on the tests
     */
    
    public static let iPhone11 = ViewImageConfig.iPhoneXr(.portrait)
    public static let iPhone11Pro = ViewImageConfig.iPhoneX(.portrait)
}

