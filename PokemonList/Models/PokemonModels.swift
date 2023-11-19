//
//  PokemonModels.swift
//  PokemonList
//
//  Created by Deev Ilyas on 15.11.2023.
//

struct PokemonList: Decodable {
    let results: [PokemonPreview]
}

struct PokemonPreview: Decodable, Equatable {
    let name: String
    let url: String

}

struct PokemonStats: Decodable {
    let value: Int
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case value = "base_stat"
        case stat
        
        enum StatKeys: String, CodingKey {
            case name
        }
    }
    
    init (from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        value = try container.decode(Int.self, forKey: .value)
        
        let statContainer = try container.nestedContainer(keyedBy: CodingKeys.StatKeys.self, forKey: .stat)
        name = try statContainer.decode(String.self, forKey: .name)
    }
}

struct PokemonDetails: Decodable {
    let height: Int
    let name: String
    let weight: Int
    let imgUrl: String
    let stats: [PokemonStats]
    
    enum CodingKeys: String, CodingKey {
        case height, name, weight, sprites, stats
        
        enum SpritesKeys: String, CodingKey {
            case other
            
            enum OtherKeys: String, CodingKey {
                case officialArtwork = "official-artwork"
                
                enum OfficialArtworkKeys: String, CodingKey {
                    case officialArtUrl = "front_default"
                }
            }
        }
    }
    
    init (from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        height = try container.decode(Int.self, forKey: .height)
        name = try container.decode(String.self, forKey: .name)
        weight = try container.decode(Int.self, forKey: .weight)
        
        let spritesContainer = try container.nestedContainer(keyedBy: CodingKeys.SpritesKeys.self, forKey: .sprites)
        let otherContainer = try spritesContainer.nestedContainer(keyedBy: CodingKeys.SpritesKeys.OtherKeys.self, forKey: .other)
        let officialArtworkContainer = try otherContainer.nestedContainer(keyedBy: CodingKeys.SpritesKeys.OtherKeys.OfficialArtworkKeys.self, forKey: .officialArtwork)
        imgUrl = try officialArtworkContainer.decode(String.self, forKey: .officialArtUrl)
        
        let stats = try container.decode([PokemonStats].self, forKey: .stats)
        
        var statsToInsert = [PokemonStats]()
        for stat in stats {
            statsToInsert.append(stat)
        }
        self.stats = statsToInsert
    }
}
