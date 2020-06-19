// 
//  ListView.swift
//  PokemonChallenge
//
//  Created by Felipe Docil on 06/02/2020.
//  Copyright © 2020 Felipe Docil. All rights reserved.
//

import SwiftUI

struct ListView: View {
    @ObservedObject var viewModel: ListViewModel

    var body: some View {
        NavigationView {
            QGrid(viewModel.pokemon, columns: 3) { pokemon in
                GridItem(viewData: pokemon)
            }
            .navigationBarTitle(Text("Pokemon"))
        }
    }
}



#if DEBUG
struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ListView(viewModel: ListViewModel.example)
            .previewDevice(PreviewDevice(rawValue: "iPhone 11"))
            .previewDisplayName("iPhone 11 Light")
            
            ListView(viewModel: ListViewModel.example)
            .previewDevice(PreviewDevice(rawValue: "iPhone 11"))
            .previewDisplayName("iPhone 11 Dark")
            .colorScheme(.dark)
        }
    }
}
#endif
