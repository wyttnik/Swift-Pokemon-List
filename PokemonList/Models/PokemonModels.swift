//
//  PokemonModels.swift
//  PokemonList
//
//  Created by Deev Ilyas on 15.11.2023.
//

struct PokemonListModel: Decodable {
    let results: [PokemonPreviewModel]
}

struct PokemonPreviewModel: Decodable {
    let name: String
    let id: String

    enum CodingKeys: String, CodingKey {
        case name
        case url
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try container.decode(String.self, forKey: CodingKeys.name)
        let url = try container.decode(String.self, forKey: CodingKeys.url)
        var flag = false
        let revUrl = url.reversed()
        var stringId = ""
        var offset = 1
        while (!flag) {
            let i = revUrl.index(revUrl.startIndex, offsetBy: offset)
            let currChar = revUrl[i]
            if (currChar == "/"){
                flag = true
            }
            else{
                stringId.append(revUrl[i])
            }
            offset += 1
        }
        id = String(stringId.reversed())
    }
    
    var dictionaryValue: [String:Any] {
        [
            "id": id,
            "name": name
        ]
    }
}

struct PokemonStats: Decodable {
    let value: String
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
        value = try String(container.decode(Int.self, forKey: .value))
        
        let statContainer = try container.nestedContainer(keyedBy: CodingKeys.StatKeys.self, forKey: .stat)
        name = try statContainer.decode(String.self, forKey: .name)
    }
}

struct PokemonDetailsModel: Decodable {
    let height: String
    let name: String
    let weight: String
    let stats: [PokemonStats]
    let id: String
    
    enum CodingKeys: String, CodingKey {
        case height, name, weight, stats, id
    }
    
    init (from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        height = try String(container.decode(Int.self, forKey: .height))
        name = try container.decode(String.self, forKey: .name)
        weight = try String(container.decode(Int.self, forKey: .weight))
        id = try String(container.decode(Int.self, forKey: .id))
        
        let stats = try container.decode([PokemonStats].self, forKey: .stats)
        
        var statsToInsert = [PokemonStats]()
        for stat in stats {
            statsToInsert.append(stat)
        }
        self.stats = statsToInsert
    }
}
