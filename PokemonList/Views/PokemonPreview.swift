//
//  PokemonPreview.swift
//  PokemonList
//
//  Created by Deev Ilyas on 15.11.2023.
//
import SwiftUI

struct PokemonPixelView: View {
    let pokemon: PokemonPreview
    let cellSize: Double
    @Environment(\.managedObjectContext) private var viewContext
    @State var uiImage: UIImage?
    @Binding var selection: String?
    
    var body: some View {
        VStack {
            if let uiImage = uiImage {
                Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: cellSize, height: cellSize)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            else {
                ProgressView()
                    .frame(width: cellSize, height: cellSize)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .task {
                        do {
                            self.uiImage = try await PokeApi.apiManager.loadPokemonImage(name: pokemon.name!,
                                                                                         id: pokemon.id!,
                                                                                         for: .preview)
                            
                        } catch {
                            print("No image folder")
                        }
                    }
            }
            
            Text("\((pokemon.name ?? "").capitalized)")
                    .font(.system(size: 16, weight: .regular, design: .monospaced))
    
        }
        .foregroundColor(.primary)
        .onTapGesture {
            self.selection = pokemon.name
            
            Task{
                try await PersistenceController.shared.fetchPokemonDetails(id: pokemon.id ?? "", name: pokemon.name ?? "")
            }
        }
        .padding([.top, .horizontal],20)
        .padding(.bottom, 10)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}
