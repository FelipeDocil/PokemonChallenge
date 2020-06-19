//
//  GridItem.swift
//  PokemonChallenge
//
//  Created by Felipe Docil on 06/02/2020.
//  Copyright © 2020 Felipe Docil. All rights reserved.
//

import SwiftUI

struct GridViewData: Identifiable {
    var id = UUID()
    var number: String
    var name: String
    var types: [Type]
    var imagePath: URL
}

struct GridItem: View {
    var viewData: GridViewData
    
    var body: some View {
        VStack(spacing: 4) {
        ImageURL(imageUrl: viewData.imagePath, placeholderImage: UIImage(imageLiteralResourceName: "pokemon_placeholder"))
          .padding([.horizontal, .top], 7)
        Text(viewData.number).lineLimit(1)
            .font(.caption)
        Text(viewData.name).lineLimit(1)
            .font(.headline)
        HStack() {
            ForEach(viewData.types, id: \.self) { type in
                TypesView(type: type)
                    .font(.caption)
                    .padding(.bottom, 7)
            }
        }
      }
    }
}

struct TypesView: View {
    var type: Type
    
    var body: some View {
        Text(type.rawValue.capitalized)
            .foregroundColor(.white)
            .padding(2)
            .background(type.color)
            .cornerRadius(4)
    }
}

#if DEBUG
// MARK: Preview

struct SwimlaneCard_Previews: PreviewProvider {
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
    
    static var previews: some View {
        Group {
            GridItem(viewData: grassPoison)
            .previewLayout(.fixed(width: 160, height: 250))
            .previewDisplayName("grass poison")
            
            GridItem(viewData: normalFlying)
            .previewLayout(.fixed(width: 160, height: 250))
            .previewDisplayName("normal flying")
            
            GridItem(viewData: fireFighting)
            .previewLayout(.fixed(width: 160, height: 250))
            .previewDisplayName("fire fighting")
            
            GridItem(viewData: waterGround)
            .previewLayout(.fixed(width: 160, height: 250))
            .previewDisplayName("water ground")
            
            GridItem(viewData: electricSteel)
            .previewLayout(.fixed(width: 160, height: 250))
            .previewDisplayName("electric steel")
            
            GridItem(viewData: psychicFairy)
            .previewLayout(.fixed(width: 160, height: 250))
            .previewDisplayName("psychic fairy")
            
            GridItem(viewData: rockIce)
            .previewLayout(.fixed(width: 160, height: 250))
            .previewDisplayName("rock ice")
            
            GridItem(viewData: bug)
            .previewLayout(.fixed(width: 160, height: 250))
            .previewDisplayName("bug")
            
            GridItem(viewData: dragonGhost)
            .previewLayout(.fixed(width: 160, height: 250))
            .previewDisplayName("dragon ghost")
            
            GridItem(viewData: dark)
            .previewLayout(.fixed(width: 160, height: 250))
            .previewDisplayName("dark")
        }
    }
}
#endif
