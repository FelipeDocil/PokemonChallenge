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
    func didSelected(row: Int)
    func search(for term: String)
    func reachEndOfPage()
}

class PokemonListPresenter: PokemonListPresenterInput, PokemonListInteractorOutput, PokemonListRouterOutput {
    var dataSource: [Pokemon] = []
    
    weak var view: PokemonListViewInput?
    var interactor: PokemonListInteractorInput
    var router: PokemonListRouterInput
    
    private var isLoading = false

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
    
    func didSelected(row: Int) {
        let pokemon = dataSource[row]
//        router.presentDetail(for: pokemon.identifier)
    }
    
    func search(for term: String) {
       /** if term.isEmpty == true {
            dataSource = interactor.localPokemon
            view?.reloadList()
            return
        }
        
        let filtered = dataSource.filter { pokemon -> Bool in
            return pokemon.name.lowercased().contains(term.lowercased())
        }
        
        dataSource = filtered
        view?.reloadList()*/
    }
    
    // MARK: Private methods
    
    private func nextPokemon() {
        if isLoading { return }
        
        isLoading = true
        interactor.pokemon { result in
            if case let .success(pokemon) = result {
                let newDatasource = pokemon.union(Set(self.dataSource))
                self.dataSource = self.order(newDatasource)
                
                // Update View
                self.view?.reloadList()
            }
            
            // Start to fetch missing images
            let downloadGroup = DispatchGroup()
            let _ = DispatchQueue.global(qos: .userInitiated)
            let missingImageList = self.dataSource.filter { return $0.image == nil || $0.shiny == nil }
            
            // Send n threads to fetch images
            let queue = DispatchQueue(label: "Update dataSource", attributes: .concurrent)
            DispatchQueue.concurrentPerform(iterations: missingImageList.count) { index in
                let pokemon = missingImageList[index]
                
                downloadGroup.enter()
                self.interactor.images(for: pokemon) { result in
                    if case let .success(pokemonWithImage) = result {
                        queue.async(flags: .barrier) {
                            self.updateDatasource(with: pokemonWithImage)
                            self.view?.reloadList()
                        }
                    }
                    
                    downloadGroup.leave()
                }
            }
            
            downloadGroup.notify(queue: DispatchQueue.main) {
                // Save to database once all images are downloaded
                self.interactor.save(pokemon: self.dataSource) {
                    // Enable for more downloads
                    self.isLoading = false
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
