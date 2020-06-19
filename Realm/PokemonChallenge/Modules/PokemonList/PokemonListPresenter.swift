// 
//  PokemonListPresenter.swift
//  PokemonChallenge
//
//  Created by Felipe Docil on 23/11/2019.
//  Copyright © 2019 Felipe Docil. All rights reserved.
//

import Foundation

protocol PokemonListPresenterInput: AnyObject {
    func viewIsReady()
    func numberOfItems() -> Int
    func cardInformation(for index: Int) -> PokemonListViewData
    func didSelected(row: Int, switchSelected: Bool)
    func search(for term: String)
    func reachEndOfPage()
    func updateImages(for identifier: Int)
}

class PokemonListPresenter: PokemonListPresenterInput, PokemonListInteractorOutput, PokemonListRouterOutput {
    var dataSource: [Pokemon] = []
    
    weak var view: PokemonListViewInput?
    var interactor: PokemonListInteractorInput
    var router: PokemonListRouterInput
    
    private var ignoreFetch = false

    init(interactor: PokemonListInteractorInput, router: PokemonListRouterInput) {
        self.interactor = interactor
        self.router = router
    }

    // MARK: PokemonListPresenterInput

    func viewIsReady() {
        view?.setupInitialState()
        
        nextPokemon()
    }
    
    func numberOfItems() -> Int {
        return dataSource.count
    }
    
    func cardInformation(for index: Int) -> PokemonListViewData {        
        let pokemon = dataSource[index]
        let viewData = PokemonListViewData(identifier: pokemon.identifier,
                                           image: pokemon.image,
                                           shiny: pokemon.shiny,
                                           name: pokemon.name)
        
        return viewData
    }
    
    func reachEndOfPage() {
        nextPokemon()
    }
    
    func didSelected(row: Int, switchSelected: Bool) {
        let pokemon = dataSource[row]
        router.presentDetail(for: pokemon.identifier, isShiny: switchSelected)
    }
    
    func search(for term: String) {
        let localDatasource = interactor.localPokemon()
        
        if term.isEmpty == true {
            ignoreFetch = false
            dataSource = order(Set(localDatasource))
            view?.reloadList()
            return
        }
        
        let filtered = localDatasource.filter { pokemon -> Bool in
            return pokemon.name.lowercased().contains(term.lowercased())
        }
        
        ignoreFetch = true
        dataSource = order(Set(filtered))
        view?.reloadList()
    }
    
    func updateImages(for identifier: Int) {
        guard let pokemon = dataSource.first(where: { $0.identifier == identifier }) else { return }
        
        let queue = DispatchQueue(label: "Update dataSource", attributes: .concurrent)
        interactor.images(for: pokemon) { result in
            if case let .success(pokemonWithImage) = result {
                queue.async(flags: .barrier) {
                    self.updateDatasource(with: pokemonWithImage)
                    self.interactor.save(pokemon: [pokemonWithImage]) {
                        self.view?.reloadList()
                    }
                }
            }
        }
    }
    
    // MARK: Private methods
    
    private func nextPokemon() {
        if ignoreFetch { return }
        
        ignoreFetch = true
        interactor.pokemon { result in
            if case let .success(pokemon) = result {
                let newDatasource = pokemon.union(Set(self.dataSource))
                let isBigger = newDatasource.count > self.dataSource.count
                
                self.dataSource = self.order(newDatasource)
                
                // Update View if it changed
                if isBigger == true {
                    self.view?.reloadList()
                    self.ignoreFetch = false
                }
            }
        }
    }
    
    private func order(_ pokemon: Set<Pokemon>) -> [Pokemon] {
        return pokemon.sorted { $0.identifier <= $1.identifier }
    }
    
    private func updateDatasource(with pokemon: Pokemon) {
        if let index = dataSource.firstIndex(where: { $0.identifier == pokemon.identifier } ) {
            dataSource[index] = pokemon
        }
    }
}
