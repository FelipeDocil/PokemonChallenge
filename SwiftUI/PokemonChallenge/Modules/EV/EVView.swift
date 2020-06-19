// 
//  EVView.swift
//  PokemonChallenge
//
//  Created by Felipe Docil on 19/02/2020.
//  Copyright © 2020 Felipe Docil. All rights reserved.
//

import SwiftUI

struct EVView: View {
    @ObservedObject var viewModel: EVViewModel

    var body: some View {
        EVItem(ev: "HP")
    }
}

struct EVItem: View {
    var ev: String
    
    var body: some View {
        VStack {
            Text(ev)
                .padding(4)
                .background(Color.purple)
                .cornerRadius(8)
            VStack {
                HStack {
                    Text("Skwovet")
                    Spacer()
                    Text("+1")
                }
            }
        }
    }
}

#if DEBUG
struct EVView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            EVView(viewModel: EVViewModel.example)
            .previewDevice(PreviewDevice(rawValue: "iPhone 11"))
            .previewDisplayName("iPhone 11 Light")
            
            EVView(viewModel: EVViewModel.example)
            .previewDevice(PreviewDevice(rawValue: "iPhone 11"))
            .previewDisplayName("iPhone 11 Dark")
            .colorScheme(.dark)
        }
    }
}
#endif
