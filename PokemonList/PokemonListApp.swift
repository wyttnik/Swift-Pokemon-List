//
//  PokemonListApp.swift
//  PokemonList
//
//  Created by Deev Ilyas on 13.11.2023.
//

import SwiftUI

@main
struct PokemonListApp: App {
    
    let pokemonController: PersistenceController = .shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, pokemonController.container.viewContext)
        }
    }
}
