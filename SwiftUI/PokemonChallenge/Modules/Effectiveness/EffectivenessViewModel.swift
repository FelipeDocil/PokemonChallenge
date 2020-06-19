// 
//  EffectivenessViewModel.swift
//  PokemonChallenge
//
//  Created by Felipe Docil on 07/02/2020.
//  Copyright © 2020 Felipe Docil. All rights reserved.
//

import Foundation

class EffectivenessServices {}

class EffectivenessViewModel: ObservableObject, Identifiable {
    struct Dependencies {
        weak var coordinator: Coordinator?
        weak var services: EffectivenessServices?
    }

    private var dependencies: Dependencies
    var types: [Type] = Type.allCases
    
    @Published var superEffective: [Type] = []
    @Published var notEffective: [Type] = []
    @Published var notVeryEffective: [Type] = []

    init(coordinator: Coordinator, services: EffectivenessServices) {
        self.dependencies = Dependencies(coordinator: coordinator, services: services)
    }
    
    func calculateEffectiveness(first: Type?, second: Type?) {
        var firstEffectiveness = first?.effectiveness ?? []
        let secondEffectiveness = second?.effectiveness ?? []
        
        let intersection = secondEffectiveness.filter { item in
            firstEffectiveness.first(where: { $0.type == item.type }) == nil
        }.compactMap( {(type: $0.type, value: 1.0)} )
        
        firstEffectiveness.append(contentsOf: intersection)
        
        var filtered: [(type: Type, value: Double)] = []
        
        for item in firstEffectiveness {
            var saveItem = item
            
            if let found = secondEffectiveness.first(where: { $0.type == item.type }) {
                saveItem = (type: found.type, value: found.value * item.value)
            }
            
            filtered.append(saveItem)
        }
        
        superEffective = filtered.filter({ item -> Bool in
            item.value >= 2
        })
            .sorted(by: { $0.value > $1.value })
            .compactMap( { $0.type } )
        
        notEffective = filtered.filter({ item -> Bool in
            item.value == 0
        })
            .compactMap( { $0.type } )
        
        notVeryEffective = filtered.filter({ item -> Bool in
            item.value < 1 && item.value > 0
        })
            .sorted(by: { $0.value < $1.value })
            .compactMap( { $0.type } )
        
    }
}

#if DEBUG
// MARK: Preview

extension EffectivenessViewModel {
    static var example: EffectivenessViewModel {
        let coordinator = Coordinator(container: Coordinator.mockPersistentContainer)
        let services = EffectivenessServices()
        let viewModel = EffectivenessViewModel(coordinator: coordinator, services: services)
        viewModel.superEffective = [.flying, .fire, .psychic, .ice]
        viewModel.notEffective = []
        viewModel.notVeryEffective = [.fighting, .water, .grass, .electric, .fairy]
        
        return viewModel
    }
}
#endif
