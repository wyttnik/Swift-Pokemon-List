//
//  PokemonListViewModel.swift
//  PokemonList
//
//  Created by Deev Ilyas on 15.11.2023.
//

import SwiftUI

class PokemonListViewModel: ObservableObject {
    @Published var pokemons = [PokemonPreview]()
    @Published var alertItem: AlertItem?
    
    init(){
        Task{
            await getPokemons()
        }
    }
    
    func getPokemons() async{
        do {
            let fetchedData = try await PokeApi.apiManager.getPokemonList()
            await MainActor.run {
                self.pokemons = fetchedData
            }
            
        } catch ApiError.wrongURL {
            print("Wrong url")
        } catch ApiError.invalidAddress {
            print("Wrong address")
        } catch ApiError.invalidServerResponse(let code) {
            await MainActor.run {
                self.alertItem = AlertItem(title: Text("Bad response"), message: Text("Error \(code)"), buttonTitle: Text("Try again?"))
            }
        } catch {
            print("Invalid data")
        }
    }
    
    func getIndex(_ pokemonPrev: PokemonPreview) -> Int {
        if let index = pokemons.firstIndex(of: pokemonPrev) {
            return index + 1
        }
        return 0
    }
}
