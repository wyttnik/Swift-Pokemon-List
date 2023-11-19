//
//  ContentView.swift
//  PokemonList
//
//  Created by Deev Ilyas on 13.11.2023.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = PokemonListViewModel()
    @StateObject var detailsViewModel = PokemonDetailsViewModel()
    @State var selection: String? = nil
    
    let columns = [GridItem(.flexible()),GridItem(.flexible())]
    
    var body: some View {
        GeometryReader{ geometry in
            
            NavigationView {
                            ScrollView{
                                LazyVGrid(columns: columns, spacing: 10) {
                                    ForEach(viewModel.pokemons, id: \.name) { pokemon in
                                        NavigationLink(destination: DetailsView(name: pokemon.name), tag: pokemon.name, selection: $selection) {
                                            PokemonPixelView(id: viewModel.getIndex(pokemon), cellSize: geometry.size.width/3, name: pokemon.name, selection: $selection)
                                        }
                                    }
                                }
                            }
                            .navigationTitle("Pokemon main page")
                            .navigationBarTitleDisplayMode(.inline)
                            .alert(item: $viewModel.alertItem) { alertItem in
                                Alert(title: alertItem.title, message: alertItem.message, dismissButton: .default(alertItem.buttonTitle,  action:{Task { await viewModel.getPokemons()}}))
                            }
            }
            .environmentObject(detailsViewModel)
            .navigationViewStyle(.stack)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
