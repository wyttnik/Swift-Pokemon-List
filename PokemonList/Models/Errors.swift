//
//  Errors.swift
//  PokemonList
//
//  Created by Deev Ilyas on 04.12.2023.
//

import Foundation

enum ApiError: Error {
    case invalidAddress
    case wrongURL
    case invalidServerResponse(_ code: Int)
    case invalidData
    case convertToPngDataError
    case batchInsertError
    case persistentHistoryChangeError
    case saveImageToDiscError
    case missingData
}
