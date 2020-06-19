// 
//  TabbarView.swift
//  PokemonChallenge
//
//  Created by Felipe Docil on 07/02/2020.
//  Copyright © 2020 Felipe Docil. All rights reserved.
//

import SwiftUI

struct TabbarView: View {
    @ObservedObject var viewModel: TabbarViewModel

    var body: some View {
        TabView {
            ListView(viewModel: viewModel.modules.list)
                .tabItem {
                    Image(systemName: "list.dash")
                    Text("List")
                }
            EffectivenessView(viewModel: viewModel.modules.effectiveness)
                .tabItem {
                    Image(systemName: "circle.grid.hex")
                    Text("Effectiveness")
                }
            EVView(viewModel: viewModel.modules.evTraining)
                .tabItem {
                    Image(systemName: "wrench")
                    Text("EV")
                }
        }
    }
}

#if DEBUG
struct TabbarView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TabbarView(viewModel: TabbarViewModel.example)
            .previewDevice(PreviewDevice(rawValue: "iPhone 11"))
            .previewDisplayName("iPhone 11 Light")
            
            TabbarView(viewModel: TabbarViewModel.example)
            .previewDevice(PreviewDevice(rawValue: "iPhone 11"))
            .previewDisplayName("iPhone 11 Dark")
            .colorScheme(.dark)
        }
    }
}
#endif
