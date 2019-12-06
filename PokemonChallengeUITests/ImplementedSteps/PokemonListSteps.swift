//
//  PokemonListSteps.swift
//  PokemonChallengeUITests
//
//  Created by Felipe Docil on 25/11/2019.
//  Copyright © 2019 Felipe Docil. All rights reserved.
//

import XCTest

extension PokemonListScreenFeatureTest {
    var app: XCUIElement {
        return XCUIApplication()
    }
}

enum PokemonListNetworkingArguments: String {
    case has = "Has"
    case hasNot = "HasNot"
    
    var arguments: [String] {
        switch self {
        case .has: return [Arguments.Networking.successPokemon.rawValue,
                           Arguments.Networking.singlePage.rawValue]
        case .hasNot: return [Arguments.Networking.noNetwork.rawValue]
        }
    }
}

enum PokemonListPersistenceArguments: String {
    case available = "Available"
    case notAvailable = "NotAvailable"
    
    var arguments: [String] {
        switch self {
        case .available: return [Arguments.Persistence.cached.rawValue]
        case .notAvailable: return [Arguments.Persistence.empty.rawValue]
        }
    }
}

// MARK: - Launch App

extension PokemonListScreenFeatureTest {
    func launchScenarioUserCanSeeTheListOfPokemon(with arguments: String, file _: StaticString = #file, line _: UInt = #line) {
        var args: [String] = [Arguments.Initial.list.rawValue]
        
        let splittedArguments = arguments.components(separatedBy: "And")
        if let persistence = splittedArguments.first, let persistenceEnum = PokemonListPersistenceArguments(rawValue: persistence) {
            args.append(contentsOf: persistenceEnum.arguments)
        }
        
        if let networking = splittedArguments.last, let networkingEnum = PokemonListNetworkingArguments(rawValue: networking) {
            args.append(contentsOf: networkingEnum.arguments)
        }
        
        launchApp(arguments: args)
    }
    
    func launchScenarioUserCanSeeAShinyPokemon(file _: StaticString = #file, line _: UInt = #line) {
        launchApp(arguments: [
            Arguments.Initial.list.rawValue,
            Arguments.Persistence.empty.rawValue,
            Arguments.Networking.successPokemon.rawValue,
            Arguments.Networking.singlePage.rawValue
        ])
    }
    
    func launchScenarioUserCanScrollToTheEndToFetchNextPage(file _: StaticString = #file, line _: UInt = #line) {
        launchApp(arguments: [
            Arguments.Initial.list.rawValue,
            Arguments.Persistence.caches.rawValue,
            Arguments.Networking.successPokemon.rawValue,
            Arguments.Networking.multiplePages.rawValue
        ])
    }
    
    func launchScenarioUserCanSeeAPokemonDetail(file _: StaticString = #file, line _: UInt = #line) {
        launchApp(arguments: [
            Arguments.Initial.list.rawValue,
            Arguments.Persistence.cached.rawValue,
            Arguments.Networking.successPokemon.rawValue,
            Arguments.Networking.singlePage.rawValue,
            Arguments.Networking.successEntry.rawValue
        ])
    }
}

// MARK: - Steps

extension PokemonListScreenFeatureTest {
    func stepUserIsOnThePokemonListScreen(file: StaticString = #file, line: UInt = #line) {
        XCTAssert(app.otherElements["pokemon_list_view"].exists, "User is not on pokemon list screen", file: file, line: line)
    }
    
    func stepUserNetworkAndPersistentItensAre(availableOrNot: String, hasOrNot: String, file: StaticString = #file, line: UInt = #line) {
        let collectionView = app.collectionViews["pokemon_list_view_collection_view"]
        XCTAssert(collectionView.exists, "User cannot see a list of pokemon", file: file, line: line)
    }
    
    func stepUserSeeTheList(canOrNot: String, file: StaticString = #file, line: UInt = #line) {
        let collectionView = app.collectionViews["pokemon_list_view_collection_view"]
        let cell = collectionView.cells["pokemon_card_1"]
                
        if canOrNot == "can" {
            XCTAssert(cell.exists, "User cannot see the first item of the list", file: file, line: line)
        } else {
            XCTAssert(cell.exists == false, "User can see the first item of the list", file: file, line: line)
        }
    }
    
    func stepUserClicksOnTheSwitch(file: StaticString = #file, line: UInt = #line) {
        let collectionView = app.collectionViews["pokemon_list_view_collection_view"]
        let cell = collectionView.cells["pokemon_card_1"]
                
        XCTAssert(cell.exists, "User cannot see the last cell", file: file, line: line)
        
        let shinySwitch = cell.switches["pokemon_card_1_shiny_switch"]
        let imageView = cell.images["pokemon_card_1_image_default"]
        
        XCTAssert(shinySwitch.exists, "User cannot see the switch", file: file, line: line)
        XCTAssert(imageView.exists, "User cannot see the default image", file: file, line: line)
        
        shinySwitch.forceTap()
    }
    
    func stepUserCanSeeAShinyVersionOfThatPokemon(file: StaticString = #file, line: UInt = #line) {
        let collectionView = app.collectionViews["pokemon_list_view_collection_view"]
        let cell = collectionView.cells["pokemon_card_1"]
        
        let imageView = cell.images["pokemon_card_1_image_shiny"]
        
        XCTAssert(imageView.exists, "User cannot see the shiny image", file: file, line: line)
    }
    
    func stepUserScrollToTheEndOfThePage(file: StaticString = #file, line: UInt = #line) {
        let collectionView = app.collectionViews["pokemon_list_view_collection_view"]
        let lastCell = collectionView.cells["pokemon_card_10"]
        
        collectionView.scrollToElement(element: lastCell)
        
        XCTAssert(lastCell.exists, "User cannot see the last cell", file: file, line: line)
    }
    
    func stepUserCanSeeTheNextPage(file: StaticString = #file, line: UInt = #line) {
        let collectionView = app.collectionViews["pokemon_list_view_collection_view"]
        let lastCellSecondPage = collectionView.cells["pokemon_card_15"]
        
        collectionView.scrollToElement(element: lastCellSecondPage)
        
        XCTAssert(lastCellSecondPage.exists, "User cannot see the last cell", file: file, line: line)
        
        let shinySwitch = lastCellSecondPage.switches["pokemon_card_15_shiny_switch"]
        var imageView = lastCellSecondPage.images["pokemon_card_15_image_default"]
        
        XCTAssert(shinySwitch.exists, "User cannot see the switch", file: file, line: line)
        XCTAssert(imageView.exists, "User cannot see the default image", file: file, line: line)
        
        shinySwitch.tap()
        
        imageView = lastCellSecondPage.images["pokemon_card_15_image_shiny"]
        
        XCTAssert(imageView.exists, "User cannot see the shiny image", file: file, line: line)
    }
    
    func stepUserClicksOnAPokemonOnTheList(file: StaticString = #file, line: UInt = #line) {
        let collectionView = app.collectionViews["pokemon_list_view_collection_view"]
        let cell = collectionView.cells["pokemon_card_1"]
                
        XCTAssert(cell.exists, "User cannot see the last cell", file: file, line: line)
        
        cell.tap()
    }
    
    func stepUserIsOnThePokemonDetailScreen(file: StaticString = #file, line: UInt = #line) {
        XCTAssert(app.otherElements["pokemon_detail_view"].exists, "User is not on pokemon detail screen", file: file, line: line)
    }
}
