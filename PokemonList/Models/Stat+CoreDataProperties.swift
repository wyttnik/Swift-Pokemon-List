//
//  Stat+CoreDataProperties.swift
//  PokemonList
//
//  Created by Deev Ilyas on 19.12.2023.
//
//

import Foundation
import CoreData


extension Stat {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Stat> {
        return NSFetchRequest<Stat>(entityName: "Stat")
    }

    @NSManaged public var value: String?
    @NSManaged public var name: String?
    @NSManaged public var id: String?
    @NSManaged public var detail: PokemonDetails?
    
    public var wrappedName: String {
        name ?? "Unknown"
    }

    public var wrappedValue: String {
        value ?? "Unknown"
    }

}

extension Stat : Identifiable {

}
