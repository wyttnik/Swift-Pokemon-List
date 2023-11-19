//
//  DetailsViewModel.swift
//  PokemonList
//
//  Created by Deev Ilyas on 15.11.2023.
//

import SwiftUI

class PokemonDetailsViewModel: ObservableObject {
    @Published var pokemonDetails: PokemonDetails?
    @Published var alertItem: AlertItem?
    
    func getPokemonInfo(_ name: String) async {
        do {
            let fetchedData = try await PokeApi.apiManager.getPokemonDetails(name)
            await MainActor.run {
                self.pokemonDetails = fetchedData
            }
            
        } catch ApiError.wrongURL {
            print("Wrong url")
        } catch ApiError.invalidAddress {
            print("Wrong address")
        } catch ApiError.invalidServerResponse(let code) {
            await MainActor.run {
                self.alertItem = AlertItem(title: Text("Bad response"), message: Text("Error \(code)"), buttonTitle: Text("Go back"))
            }
        } catch {
            print("Invalid data")
        }
    }
}

