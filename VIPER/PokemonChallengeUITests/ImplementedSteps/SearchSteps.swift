//
//  SearchSteps.swift
//  PokemonChallengeUITests
//
//  Created by Felipe Docil on 18/12/2019.
//  Copyright © 2019 Felipe Docil. All rights reserved.
//

import XCTest

extension SearchAPokemonFeatureTest {
    var app: XCUIElement {
        return XCUIApplication()
    }
}

// MARK: - Launch App

extension SearchAPokemonFeatureTest {
    var arguments: [String] {
        [
            Arguments.Initial.list.rawValue,
            Arguments.Persistence.caches.rawValue,
            Arguments.Networking.successPokemon.rawValue,
            Arguments.Networking.singlePage.rawValue,
            Arguments.Networking.successEntry.rawValue
        ]
    }
    
    func launchScenarioUserCanSearchAPokemon(file _: StaticString = #file, line _: UInt = #line) {
        launchApp(arguments: arguments)
    }
    
    func launchScenarioUserSeesAnEmptyListIfSearchForAnInexistentPokemon(file _: StaticString = #file, line _: UInt = #line) {
        launchApp(arguments: arguments)
    }
    
    func launchScenarioUserCanSeeADetailOfASearchPokemon(file _: StaticString = #file, line _: UInt = #line) {
        launchApp(arguments: arguments)
    }
    
    func launchScenarioUserCanSeeADetailOfASearchShinyPokemon(file _: StaticString = #file, line _: UInt = #line) {
        launchApp(arguments: arguments)
    }
}

// MARK: - Steps

extension SearchAPokemonFeatureTest {
    func stepUserIsOnThePokemonListScreen(file: StaticString = #file, line: UInt = #line) {
        XCTAssert(app.otherElements["pokemon_list_view"].exists, "User is not on pokemon list screen", file: file, line: line)
    }
    
    func stepUserSearchesForAnExistentPokemon(file: StaticString = #file, line: UInt = #line) {
        let searchBar = app.otherElements["pokemon_list_view_search_bar"]
        XCTAssert(searchBar.exists, "User cannot see the search bar", file: file, line: line)
        
        searchBar.tap()
        searchBar.typeText("Bulbasaur")
    }
    
    func stepUserSearchesForAnInexistentPokemon(file: StaticString = #file, line: UInt = #line) {
        let searchBar = app.otherElements["pokemon_list_view_search_bar"]
        XCTAssert(searchBar.exists, "User cannot see the search bar", file: file, line: line)
        
        searchBar.tap()
        searchBar.typeText("FAKE_POKEMON")
    }
    
    func stepUserCanSeeAListWithOnlyThisPokemon(file: StaticString = #file, line: UInt = #line) {
        let collectionView = app.collectionViews["pokemon_list_view_collection_view"]
        XCTAssert(collectionView.exists, "User cannot see a list of pokemon", file: file, line: line)
        
        let cell = collectionView.cells["pokemon_card_1"]
        
        XCTAssert(cell.exists, "User cannot see searched cell", file: file, line: line)
        XCTAssert(collectionView.cells.count == 1, "User can see more than one cell", file: file, line: line)
    }
    
    func stepUserSeesAnEmptyList(file: StaticString = #file, line: UInt = #line) {
        let collectionView = app.collectionViews["pokemon_list_view_collection_view"]
        XCTAssert(collectionView.exists, "User cannot see a list of pokemon", file: file, line: line)
        
        XCTAssert(collectionView.cells.count == 0, "User can see some cell", file: file, line: line)
    }
    
    func stepUserClicksOnAPokemonOnTheList(file: StaticString = #file, line: UInt = #line) {
        let collectionView = app.collectionViews["pokemon_list_view_collection_view"]
        XCTAssert(collectionView.exists, "User cannot see a list of pokemon", file: file, line: line)
        
        let cell = collectionView.cells["pokemon_card_1"]
        XCTAssert(cell.exists, "User cannot see searched cell", file: file, line: line)
        
        cell.tap()
    }
    
    func stepUserIsOnThePokemonDetailScreen(file: StaticString = #file, line: UInt = #line) {
        XCTAssert(app.otherElements["pokemon_detail_view"].exists, "User is not on pokemon detail screen", file: file, line: line)
        
        let image = app.images["pokemon_detail_view_image_view_default"]
        XCTAssert(image.exists, "User cannot see a pokemon image", file: file, line: line)
        
        let title = app.staticTexts["pokemon_detail_view_name_label"].label
        XCTAssert(title.contains("Shiny") == false, "Title does contain Shiny", file: file, line: line)
    }
    
    
    func stepUserClicksOnTheSwitch(file: StaticString = #file, line: UInt = #line) {
        let collectionView = app.collectionViews["pokemon_list_view_collection_view"]
        let cell = collectionView.cells["pokemon_card_1"]
                
        XCTAssert(cell.exists, "User cannot see the searched cell", file: file, line: line)
        
        let shinySwitch = cell.switches["pokemon_card_1_shiny_switch"]
        let imageView = cell.images["pokemon_card_1_image_default"]
        
        XCTAssert(shinySwitch.exists, "User cannot see the switch", file: file, line: line)
        XCTAssert(imageView.exists, "User cannot see the default image", file: file, line: line)
        
        shinySwitch.forceTap()
    }
    
    func stepUserIsOnThePokemonDetailScreenOfAShinyPokemon(file: StaticString = #file, line: UInt = #line) {
        XCTAssert(app.otherElements["pokemon_detail_view"].exists, "User is not on pokemon detail screen", file: file, line: line)
        
        let image = app.images["pokemon_detail_view_image_view_shiny"]
        XCTAssert(image.exists, "User cannot see a pokemon image", file: file, line: line)
        
        let title = app.staticTexts["pokemon_detail_view_name_label"].label
        XCTAssert(title.contains("Shiny"), "Title does not contain Shiny", file: file, line: line)
    }
}
