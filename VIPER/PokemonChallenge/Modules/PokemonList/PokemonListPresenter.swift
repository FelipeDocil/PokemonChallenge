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
    func loadNewPokemon()
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
        dataSource.count
    }

    func cardInformation(for index: Int) -> PokemonListViewData {
        let pokemon = dataSource[index]
        let viewData = PokemonListViewData(identifier: pokemon.identifier,
                                           image: pokemon.image,
                                           shiny: pokemon.shiny,
                                           name: pokemon.name)

        return viewData
    }

    func loadNewPokemon() {
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
            dataSource = localDatasource
            view?.reloadList()
            return
        }

        let filtered = localDatasource.filter { pokemon -> Bool in
            pokemon.name.lowercased().contains(term.lowercased())
        }

        ignoreFetch = true
        dataSource = filtered
        view?.reloadList()
    }

    func updateImages(for identifier: Int) {
        guard let pokemon = dataSource.first(where: { $0.identifier == identifier }) else { return }

        let queue = DispatchQueue(label: "Update dataSource", attributes: .concurrent)
        interactor.images(for: pokemon) { result in
            if case let .success(pokemonWithImage) = result {
                queue.async(flags: .barrier) {
                    self.updateDatasource(with: pokemonWithImage)
                    self.view?.reloadList()
                    self.interactor.save(pokemon: [pokemonWithImage])
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
                let isBigger = pokemon.count > self.dataSource.count
                self.dataSource = pokemon

                // Update View if it has changed
                if isBigger == true {
                    self.view?.reloadList()
                    self.ignoreFetch = false
                }
            }

            self.view?.stopLoading()
        }
    }

    private func order(_ pokemon: Set<Pokemon>) -> [Pokemon] {
        pokemon.sorted { $0.identifier <= $1.identifier }
    }

    private func updateDatasource(with pokemon: Pokemon) {
        if let index = dataSource.firstIndex(where: { $0.identifier == pokemon.identifier } ) {
            dataSource[index] = pokemon
        }
    }
}
