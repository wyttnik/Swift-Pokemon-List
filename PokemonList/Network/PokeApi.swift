//
//  PokeApi.swift
//  PokemonList
//
//  Created by Deev Ilyas on 13.11.2023.
//
import SwiftUI

struct PokeApi {
    static let apiManager = PokeApi()
    private let apiURL = "https://pokeapi.co/api/v2/"
    
    func getPokemonList() async throws -> [PokemonPreview] {
        guard let url = URL(string: apiURL + "pokemon/") else{
            throw ApiError.wrongURL
        }
        
        guard let (data, response) = try? await URLSession.shared.data(from: url) else {
            print("couldn't get data")
            throw ApiError.invalidAddress
        }

        let httpResponse = response as? HTTPURLResponse
        if (httpResponse?.statusCode != 200) {
            throw ApiError.invalidServerResponse(httpResponse!.statusCode)
        }

        guard let pokemons = try? JSONDecoder().decode(PokemonList.self, from: data) else{
            throw ApiError.invalidData
        }

        return pokemons.results
    }
    
    func getPokemonDetails(_ name: String) async throws -> PokemonDetails {
        guard let url = URL(string: apiURL + "pokemon/\(name)") else{
            throw ApiError.wrongURL
        }
        
        guard let (data, response) = try? await URLSession.shared.data(from: url) else {
            print("couldn't get data")
            throw ApiError.invalidAddress
        }

        let httpResponse = response as? HTTPURLResponse
        if (httpResponse?.statusCode != 200) {
            throw ApiError.invalidServerResponse(httpResponse!.statusCode)
        }

        guard let pokemonDetails = try? JSONDecoder().decode(PokemonDetails.self, from: data) else{
            throw ApiError.invalidData
        }

        return pokemonDetails
    }
    
    
    
}

enum ApiError: Error {
    case invalidAddress
    case wrongURL
    case invalidServerResponse(_ code: Int)
    case invalidData
}
