// 
//  ListViewModel.swift
//  PokemonChallenge
//
//  Created by Felipe Docil on 06/02/2020.
//  Copyright © 2020 Felipe Docil. All rights reserved.
//

import Foundation

class ListServices {
    var databaseService: DatabaseServiceInput
    
    init(databaseService: DatabaseServiceInput) {
        self.databaseService = databaseService
    }
}

class ListViewModel: ObservableObject, Identifiable {
    struct Dependencies {
        weak var coordinator: Coordinator?
        weak var services: ListServices?
    }

    private var dependencies: Dependencies
    
    @Published var pokemon: [GridViewData] = []

    init(coordinator: Coordinator, services: ListServices) {
        self.dependencies = Dependencies(coordinator: coordinator, services: services)
    }
    
    // MARK: Private methods
    private func gridViewData(from pokemon: Pokemon) -> GridViewData {
        GridViewData(number: String(format: "%03d", pokemon.number),
                     name: pokemon.name.capitalized,
                     types: pokemon.types.compactMap(Type.init),
                     imagePath: pokemon.imagePath)
    }
}

#if DEBUG
// MARK: Preview

extension ListViewModel {
    static var grassPoison: GridViewData {
        GridViewData(number: "#003", name: "Venusaur", types: [.grass, .poison], imagePath: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/3.png")!)
    }
    
    static var normalFlying: GridViewData {
        GridViewData(number: "#016", name: "Pidgey", types: [.normal, .flying], imagePath: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/16.png")!)
    }
    
    static var fireFighting: GridViewData {
        GridViewData(number: "#257", name: "Blaziken", types: [.fire, .fighting], imagePath: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/257.png")!)
    }
    
    static var waterGround: GridViewData {
        GridViewData(number: "#260", name: "Swampert", types: [.water, .ground], imagePath: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/260.png")!)
    }
    
    static var electricSteel: GridViewData {
        GridViewData(number: "#082", name: "Magneton", types: [.electric, .steel], imagePath: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/82.png")!)
    }
    
    static var psychicFairy: GridViewData {
        GridViewData(number: "#122", name: "Mr. Mime", types: [.psychic, .fairy], imagePath: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/122.png")!)
    }
    
    static var rockIce: GridViewData {
        GridViewData(number: "#699", name: "Aurorus", types: [.rock, .ice], imagePath: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/699.png")!)
    }
    
    static var bug: GridViewData {
        GridViewData(number: "#127", name: "Pinsir", types: [.bug], imagePath: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/127.png")!)
    }
    
    static var dragonGhost: GridViewData {
        GridViewData(number: "#887", name: "Dragapult", types: [.dragon, .ghost], imagePath: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/887.png")!)
    }
    
    static var dark: GridViewData {
        GridViewData(number: "#359", name: "Absol", types: [.dark], imagePath: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/359.png")!)
    }
    
    static var example: ListViewModel {
        // Service
        let container = Coordinator.mockPersistentContainer
        let database = DatabaseService(container: container)
        
        let coordinator = Coordinator(container: Coordinator.mockPersistentContainer)
        let services = ListServices(databaseService: database)
        let viewModel = ListViewModel(coordinator: coordinator, services: services)
        
        viewModel.pokemon = [grassPoison, normalFlying, fireFighting, waterGround, electricSteel, psychicFairy, rockIce, bug, dragonGhost, dark]
        
        return viewModel
    }
}
#endif
