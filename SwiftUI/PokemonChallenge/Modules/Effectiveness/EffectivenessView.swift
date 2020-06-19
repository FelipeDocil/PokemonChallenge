// 
//  EffectivenessView.swift
//  PokemonChallenge
//
//  Created by Felipe Docil on 07/02/2020.
//  Copyright © 2020 Felipe Docil. All rights reserved.
//

import SwiftUI

struct EffectivenessView: View {
    @ObservedObject var viewModel: EffectivenessViewModel
    @State var firstType: Type?
    @State var secondType: Type?

    var body: some View {
        NavigationView {
            VStack() {
                QGrid(viewModel.types, columns: 4) { type in
                    Button(
                        action: {
                            self.selectType(with: type)
                        },
                        label: { TypesView(type: type).font(.body) }
                    )
                }
                
                HStack {
                    firstType.map({ TypesView(type: $0) })
                    secondType.map({ TypesView(type: $0) })
                }.padding(.bottom, 16)
                
                List {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Super effective")
                        HStack() {
                            ForEach(viewModel.superEffective) { type in
                                TypesView(type: type).font(.caption)
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Not effective")
                        HStack() {
                            ForEach(viewModel.notEffective) { type in
                                TypesView(type: type).font(.caption)
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Not very effective")
                        HStack() {
                            ForEach(viewModel.notVeryEffective) { type in
                                TypesView(type: type).font(.caption)
                            }
                        }
                    }
                }
            }
            .navigationBarTitle(Text("Effectiveness"))
        }
    }
    
    private func selectType(with type: Type) {
        if secondType == nil && firstType != nil && type != firstType {
            secondType = type
        } else if secondType != nil && type != secondType {
            firstType = secondType
            secondType = type
        } else {
            firstType = type
            secondType = nil
        }
        
        viewModel.calculateEffectiveness(first: firstType, second: secondType)
    }
}

#if DEBUG
struct EffectivenessView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            EffectivenessView(viewModel: EffectivenessViewModel.example, firstType: .grass, secondType: .poison)
            .previewDevice(PreviewDevice(rawValue: "iPhone 11"))
            .previewDisplayName("iPhone 11 Light")
            
            EffectivenessView(viewModel: EffectivenessViewModel.example, firstType: .grass, secondType: .poison)
            .previewDevice(PreviewDevice(rawValue: "iPhone 11"))
            .previewDisplayName("iPhone 11 Dark")
            .colorScheme(.dark)
        }
    }
}
#endif
