// 
//  PokemonDetailPresenter.swift
//  PokemonChallenge
//
//  Created by Felipe Docil on 04/12/2019.
//  Copyright © 2019 Felipe Docil. All rights reserved.
//

import Foundation

protocol PokemonDetailPresenterInput: AnyObject {
    func viewIsReady()
}

class PokemonDetailPresenter: PokemonDetailPresenterInput, PokemonDetailInteractorOutput, PokemonDetailRouterOutput {
    weak var view: PokemonDetailViewInput?
    var interactor: PokemonDetailInteractorInput
    var router: PokemonDetailRouterInput
    var identifier: Int
    var isShiny: Bool

    init(interactor: PokemonDetailInteractorInput, router: PokemonDetailRouterInput, identifier: Int, isShiny: Bool) {
        self.interactor = interactor
        self.router = router
        self.identifier = identifier
        self.isShiny = isShiny
    }

    // MARK: PokemonDetailPresenterInput

    func viewIsReady() {
        let pokemon = interactor.information(for: identifier, isShiny: isShiny)
        let viewData = PokemonDetailViewData(image: pokemon.image, name: pokemon.name, isShiny: isShiny)
        view?.setupInitialState(with: viewData)
        
        entries()
    }
    
    // MARK: Private methods
    
    private func entries() {
        interactor.fetchEntries(for: identifier) { result in
            if case let .success(entries) = result {
                let englishLanguageEntries = entries.filter { entry -> Bool in
                    return entry.language.lowercased() == "en"
                }
                
                var sourceDict: [(key: String, value: String)] = []
                for entry in englishLanguageEntries {
                    sourceDict.append((key: entry.version, value: entry.flavorText.replacingOccurrences(of: "\n", with: " ").replacingOccurrences(of: "\u{0C}", with: " ")))
                }
                
                var uniqueValues = Set<String>()
                var resultDict = [String: String](minimumCapacity: sourceDict.count)
                
                for (key, value) in sourceDict {
                    if !uniqueValues.contains(value) {
                        uniqueValues.insert(value)
                        resultDict[key] = value
                    } else {
                        guard let matchingKey = resultDict.allKeys(for: value).first else { continue }
                        resultDict.removeValue(forKey: matchingKey)
                        
                        resultDict["\(matchingKey) \(key)"] = value
                    }
                }
                
                var entryViewData = [(pokedex: [String], text: String)]()
                for (key, value) in resultDict {
                    entryViewData.append((pokedex: key.split(separator: " ").map(String.init), text: value))
                }
                
                DispatchQueue.main.async {
                    self.view?.updateEntries(texts: entryViewData)
                }
                
                self.interactor.save(entries: englishLanguageEntries, into: self.identifier)
            }
        }
    }
}

extension Dictionary where Value: Equatable {
    func allKeys(for value: Value) -> [Key] {
        return self.filter { $1 == value }.map { $0.0 }
    }
}
