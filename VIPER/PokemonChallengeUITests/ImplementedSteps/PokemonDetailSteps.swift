//
//  PokemonDetailSteps.swift
//  PokemonChallengeUITests
//
//  Created by Felipe Docil on 15/12/2019.
//  Copyright © 2019 Felipe Docil. All rights reserved.
//

import XCTest

extension PokemonDetailScreenFeatureTest {
    var app: XCUIElement {
        return XCUIApplication()
    }
}

enum PokemonDetailNetworkingArguments: String {
    case has = "Has"
    case hasNot = "HasNot"

    var arguments: [String] {
        switch self {
        case .has: return [Arguments.Networking.successEntry.rawValue]
        case .hasNot: return [Arguments.Networking.noNetwork.rawValue]
        }
    }
}

enum PokemonDetailPersistenceArguments: String {
    case available = "Available"
    case notAvailable = "NotAvailable"

    var arguments: [String] {
        switch self {
        case .available: return [Arguments.Persistence.initialEntry.rawValue]
        case .notAvailable: return [Arguments.Persistence.empty.rawValue]
        }
    }
}

// MARK: - Launch App

extension PokemonDetailScreenFeatureTest {
    func launchScenarioUserCanSeeTheDetailOfPokemon(with arguments: String, file _: StaticString = #file, line _: UInt = #line) {
        var args: [String] = [Arguments.Initial.detail.rawValue]

        let splittedArguments = arguments.components(separatedBy: "And")
        if let persistence = splittedArguments.first, let persistenceEnum = PokemonDetailPersistenceArguments(rawValue: persistence) {
            args.append(contentsOf: persistenceEnum.arguments)
        }

        if let networking = splittedArguments.last, let networkingEnum = PokemonDetailNetworkingArguments(rawValue: networking) {
            args.append(contentsOf: networkingEnum.arguments)
        }

        launchApp(arguments: args)
    }

    func launchScenarioUserCanSeeADetailOfAShinyPokemon(file _: StaticString = #file, line _: UInt = #line) {
        launchApp(arguments: [
            Arguments.Initial.detailShiny.rawValue,
            Arguments.Persistence.initialEntry.rawValue,
            Arguments.Networking.successEntry.rawValue
        ])
    }
}

// MARK: - Steps

extension PokemonDetailScreenFeatureTest {
    func stepUserIsOnThePokemonDetailScreen(file: StaticString = #file, line: UInt = #line) {
        XCTAssert(app.otherElements["pokemon_detail_view"].exists, "User is not on pokemon detail screen", file: file, line: line)
    }

    func stepUserIsOnThePokemonDetailScreenOfAShinyPokemon(file: StaticString = #file, line: UInt = #line) {
        XCTAssert(app.otherElements["pokemon_detail_view"].exists, "User is not on pokemon detail screen", file: file, line: line)
    }

    func stepUserNetworkAndPersistentItensAre(availableOrNot: String, hasOrNot: String, file: StaticString = #file, line: UInt = #line) {
        let image = app.images["pokemon_detail_view_image_view_default"]
        XCTAssert(image.exists, "User cannot see a pokemon image", file: file, line: line)

        let title = app.staticTexts["pokemon_detail_view_name_label"].label
        XCTAssert(title.contains("Shiny") == false, "Title does contain Shiny", file: file, line: line)
    }

    func stepUserSeeThePokedexEntries(canOrNot: String, file: StaticString = #file, line: UInt = #line) {
        let entry = app.staticTexts["pokemon_detail_view_entry_label"]

        if canOrNot == "can" {
            XCTAssert(entry.label.isEmpty == false, "User cannot see the entries of Pokemon pokedex", file: file, line: line)
        } else {
            XCTAssert(entry.exists == false, "User can see the entries of Pokemon pokedex", file: file, line: line)
        }
    }

    func stepUserCanSeeAShinyImageAndShinyOnTheTitle(file: StaticString = #file, line: UInt = #line) {
        let image = app.images["pokemon_detail_view_image_view_shiny"]
        XCTAssert(image.exists, "User cannot see a pokemon image", file: file, line: line)

        let title = app.staticTexts["pokemon_detail_view_name_label"].label
        XCTAssert(title.contains("Shiny"), "Title does not contain Shiny", file: file, line: line)
    }
}
