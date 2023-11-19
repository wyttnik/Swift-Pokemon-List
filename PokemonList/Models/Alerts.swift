//
//  Alerts.swift
//  PokemonList
//
//  Created by Deev Ilyas on 15.11.2023.
//

import SwiftUI

struct AlertItem: Identifiable {
    let id = UUID()
    var title:Text
    var message:Text
    var buttonTitle:Text
}
