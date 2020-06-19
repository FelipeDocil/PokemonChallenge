// 
//  EVViewModel.swift
//  PokemonChallenge
//
//  Created by Felipe Docil on 19/02/2020.
//  Copyright © 2020 Felipe Docil. All rights reserved.
//

import Foundation

class EVServices {}

class EVViewModel: ObservableObject, Identifiable {
    struct Dependencies {
        weak var coordinator: Coordinator?
        weak var services: EVServices?
    }

    private var dependencies: Dependencies

    init(coordinator: Coordinator, services: EVServices) {
        self.dependencies = Dependencies(coordinator: coordinator, services: services)
    }
}

#if DEBUG
// MARK: Preview

extension EVViewModel {
    static var example: EVViewModel {
        let coordinator = Coordinator(container: Coordinator.mockPersistentContainer)
        let services = EVServices()
        return EVViewModel(coordinator: coordinator, services: services)
    }
}
#endif
