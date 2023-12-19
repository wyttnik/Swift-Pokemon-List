//
//  PokeApi.swift
//  PokemonList
//
//  Created by Deev Ilyas on 13.11.2023.
//
import SwiftUI

enum EntityType{
    case preview
    case details
}

struct PokeApi {
    static let apiManager = PokeApi()
    private let apiURL = "https://pokeapi.co/api/v2/"
    
    func getPokemonList() async throws -> [PokemonPreviewModel] {
        
        guard let url = URL(string: apiURL + "pokemon?limit=80&offset=0") else{
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

        guard let pokemons = try? JSONDecoder().decode(PokemonListModel.self, from: data) else{
            throw ApiError.invalidData
        }

        return pokemons.results
    }
    
    func getPokemonDetails(_ name: String) async throws -> PokemonDetailsModel {
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

        guard let pokemonDetails = try? JSONDecoder().decode(PokemonDetailsModel.self, from: data) else{
            throw ApiError.invalidData
        }

        return pokemonDetails
    }
    
    func downloadImage(_ id: String, for type: EntityType) async throws -> UIImage {
        var url:URL? = nil
        switch type {
        case .preview:
            url = URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(id).png")
        case .details:
            url = URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(id).png")
        }
        if (url == nil) {
            throw ApiError.wrongURL
        }
        
        
        guard let (data, response) = try? await URLSession.shared.data(from: url!) else {
            print("couldn't get data")
            throw ApiError.invalidAddress
        }
        
        let httpResponse = response as? HTTPURLResponse
        if (httpResponse?.statusCode != 200) {
            throw ApiError.invalidServerResponse(httpResponse!.statusCode)
        }
        
        guard let pokemonImage = UIImage(data: data) else{
            throw ApiError.invalidData
        }
        
        return pokemonImage
    }
    
    func savePokemonImage(_ name:String, for id: String, ofType type: EntityType) async throws {
        let pokemonImage: UIImage
        switch type {
        case .preview:
            pokemonImage = try await downloadImage(id, for: .preview)
        case .details:
            pokemonImage = try await downloadImage(id, for: .details)
        }
        
        guard let imageData = pokemonImage.pngData() else {
            throw ApiError.convertToPngDataError
        }
        
        let manager = FileManager.default
        let folderURL = try manager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        
        let nestedFolderURL:URL
        switch type {
        case .preview:
            nestedFolderURL = folderURL.appendingPathComponent("PokemonPreviews")
        case .details:
            nestedFolderURL = folderURL.appendingPathComponent("PokemonDetails")
        }
        
        do {
            try manager.createDirectory(
                at: nestedFolderURL,
                withIntermediateDirectories: false,
                attributes: nil)
        } catch CocoaError.fileWriteFileExists{}
        catch { throw error }
        
        let fileURL = nestedFolderURL.appendingPathComponent("\(name)")
        
        try imageData.write(to: fileURL)
    }
    
    func loadPokemonImage(name:String, id:String, for type: EntityType) async throws -> UIImage? {
        let manager = FileManager.default
        let folderURL = try manager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let nestedFolderURL:URL
        switch type {
        case .preview:
            nestedFolderURL = folderURL.appendingPathComponent("PokemonPreviews")
        case .details:
            nestedFolderURL = folderURL.appendingPathComponent("PokemonDetails")
        }
        let fileURL = nestedFolderURL.appendingPathComponent("\(name)")
        
        if !manager.fileExists(atPath: fileURL.path) {
            switch type {
            case .preview:
                return try await downloadImage(id, for: .preview)
            case.details:
                return try await downloadImage(id, for: .details)
            }
        }
        else {
            return UIImage(contentsOfFile: fileURL.path)
        }
    }
}


