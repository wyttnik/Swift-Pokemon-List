//
//  ContentView.swift
//  PokemonList
//
//  Created by Deev Ilyas on 13.11.2023.
//

import SwiftUI

struct ContentView: View {
//    @StateObject var detailsViewModel = PokemonDetailsViewModel()
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject var viewModel = PersistenceController.shared.contentViewModel
    @State var selection: String? = nil
    @State var isLoading = false
    @State var hasError = false
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.id)])
    private var pokemons: FetchedResults<PokemonPreview>
    
    
    let columns = [GridItem(.flexible()),GridItem(.flexible())]
    
    var body: some View {
        GeometryReader{ geometry in
            NavigationView {
                ScrollView{
                    LazyVGrid(columns: columns,spacing: 10) {
                        ForEach(pokemons, id: \.id) { pokemon in
                            NavigationLink(destination: DetailsView(id: pokemon.id ?? "1"), tag: pokemon.name ?? "", selection: $selection) {
                                PokemonPixelView(pokemon: pokemon, cellSize: geometry.size.width/3, selection: $selection)
                            }
                        }
                    }
                }
                .navigationBarTitle("Pokemon main page")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing: Button(action: {
                    Task{
                        await fetchPokemons()
                    }
                }) {
                    Image(systemName: "arrow.2.circlepath")}.disabled(isLoading)
                )
                .alert(item: $viewModel.alertItem) { alertItem in
                    Alert(title: alertItem.title,
                          message: alertItem.message,
                          dismissButton: .default(alertItem.buttonTitle,action:{Task { await fetchPokemons()}}))
                }
            }
//            .environmentObject(detailsViewModel)
            .navigationViewStyle(.stack)
        }
    }
}

extension ContentView {
    private func fetchPokemons() async {
        isLoading = true
        do {
            try await PersistenceController.shared.fetchPokemons()
        } catch {
            //self.error = error as? QuakeError ?? .unexpectedError(error: error)
            self.hasError = true
        }
        isLoading = false
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
