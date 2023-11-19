//
//  PokemonPreview.swift
//  PokemonList
//
//  Created by Deev Ilyas on 15.11.2023.
//
import SwiftUI

struct PokemonPixelView: View {
    let id: Int
    let cellSize: Double
    let name: String
    @Binding var selection: String?
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(id).png")) { phase in
                switch phase {
                case .failure: Image(systemName: "photo").frame(width: cellSize, height: cellSize)
                case .success(let image): image
                        .resizable()
                        .scaledToFit()
                        .frame(width: cellSize, height: cellSize)
                default: ProgressView()
                        .frame(width: cellSize, height: cellSize)
                }}
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            Text("\(name.capitalized)")
                    .font(.system(size: 16, weight: .regular, design: .monospaced))
    
        }
        .foregroundColor(.primary)
        .onTapGesture {
            self.selection = name
        }
        .padding([.top, .horizontal],20)
        .padding(.bottom, 10)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}
