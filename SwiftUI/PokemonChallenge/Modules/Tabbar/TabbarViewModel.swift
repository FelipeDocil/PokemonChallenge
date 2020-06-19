// 
//  TabbarViewModel.swift
//  PokemonChallenge
//
//  Created by Felipe Docil on 07/02/2020.
//  Copyright © 2020 Felipe Docil. All rights reserved.
//

import Foundation

class TabbarModules {
    var list: ListViewModel
    var effectiveness: EffectivenessViewModel
    var evTraining: EVViewModel
    
    init(list: ListViewModel, effectiveness: EffectivenessViewModel, evTraining: EVViewModel) {
        self.list = list
        self.effectiveness = effectiveness
        self.evTraining = evTraining
    }
}

class TabbarServices {}

class TabbarViewModel: ObservableObject, Identifiable {
    struct Dependencies {
        weak var coordinator: Coordinator?
        weak var services: TabbarServices?
    }

    private var dependencies: Dependencies
    var modules: TabbarModules

    init(coordinator: Coordinator, services: TabbarServices, modules: TabbarModules) {
        self.dependencies = Dependencies(coordinator: coordinator, services: services)
        self.modules = modules
    }
}

#if DEBUG
// MARK: Preview

extension TabbarViewModel {
    static var example: TabbarViewModel {
        let list = ListViewModel.example
        let effectiveness = EffectivenessViewModel.example
        let ev = EVViewModel.example
        
        let coordinator = Coordinator(container: Coordinator.mockPersistentContainer)
        let services = TabbarServices()
        let modules = TabbarModules(list: list, effectiveness: effectiveness, evTraining: ev)
        
        return TabbarViewModel(coordinator: coordinator, services: services, modules: modules)
    }
}
#endif
