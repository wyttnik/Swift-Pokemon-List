//
//  PokemonDetails+CoreDataProperties.swift
//  PokemonList
//
//  Created by Deev Ilyas on 19.12.2023.
//
//

import Foundation
import CoreData


extension PokemonDetails {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PokemonDetails> {
        return NSFetchRequest<PokemonDetails>(entityName: "PokemonDetails")
    }

    @NSManaged public var height: String?
    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var weight: String?
    @NSManaged public var stat: NSSet?

    public var statArray: [Stat] {
        let set = stat as? Set<Stat> ?? []
        
        return set.sorted {
            $0.wrappedName < $1.wrappedName
        }
    }
}

// MARK: Generated accessors for stat
extension PokemonDetails {

    @objc(addStatObject:)
    @NSManaged public func addToStat(_ value: Stat)

    @objc(removeStatObject:)
    @NSManaged public func removeFromStat(_ value: Stat)

    @objc(addStat:)
    @NSManaged public func addToStat(_ values: NSSet)

    @objc(removeStat:)
    @NSManaged public func removeFromStat(_ values: NSSet)

}

extension PokemonDetails : Identifiable {

}
