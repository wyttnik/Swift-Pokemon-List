//
//  Persistence.swift
//  PokemonList
//
//  Created by Deev Ilyas on 04.12.2023.
//

import OSLog
import CoreData
import SwiftUI

class PersistenceController {

    let logger = Logger(subsystem: "com.supercompany.PokemonList", category: "persistece")
    private let urlsToDel = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let contentViewModel = PokemonListViewModel()
    let detailsViewModel = PokemonDetailsViewModel()

    /// A shared persistant controller for use within main app bundle
    static let shared = PersistenceController()


    private let inMemory: Bool
    private var notificationToken: NSObjectProtocol?

    private init(inMemory: Bool = false) {
        self.inMemory = inMemory

        // Observer Core Data remote change notifications on the queue where the changes were made.
        notificationToken = NotificationCenter.default.addObserver(forName: .NSPersistentStoreRemoteChange, object: nil, queue: nil) { note in
            self.logger.debug("Received a persistent store remote change notification.")
            Task {
                await self.fetchPersistentHistory()
            }

        }
    }

    deinit {
        if let observer = notificationToken {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    /// A persistent history token used for fetching transactions from the store
    private var lastToken: NSPersistentHistoryToken?

    /// A persistent container to set up the Core Data stack
    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Pokemon")

        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("Failed to retrieve a persistent store description")
        }

        if (inMemory) {
            description.url = URL(fileURLWithPath: "/dev/null")
        }

        // Enable persistent store remote change notifications
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        // Enable persistent history tracking
        description.setOption(true as NSNumber,
                              forKey: NSPersistentHistoryTrackingKey)
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolver error \(error), \(error.userInfo)")
            }
        }

        // refresh UI bu consuming store changes via persistent history tracking
        container.viewContext.automaticallyMergesChangesFromParent = false
        container.viewContext.name = "viewContext"
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy   //NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.undoManager = nil
        container.viewContext.shouldDeleteInaccessibleFaults = true

        return container
    }()

    /// Creates and configures a private queue context
    private func newTaskContext() -> NSManagedObjectContext {
        let taskContext = container.newBackgroundContext()
        taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        taskContext.undoManager = nil
        return taskContext
    }

    func fetchPokemons() async throws {
        do {
            // Decode pokemon previews to a data model.
            let pokemons = try await PokeApi.apiManager.getPokemonList()
            logger.debug("Received \(pokemons.count) records.")
            
            // Import pokemon previews into Core Data.
            logger.debug("Start importing data to the store...")
            try await importPokemons(from: pokemons)
            logger.debug("Finished importing data.")
            
        } catch ApiError.wrongURL {
            print("Wrong url")
        } catch ApiError.invalidAddress {
            print("Wrong address")
        } catch ApiError.invalidServerResponse(let code) {
            contentViewModel.alertItem = AlertItem(title: Text("Bad response"), message: Text("Error \(code)"), buttonTitle: Text("Try again?"))
        } catch {
            print("Invalid data")
        }
    }
    
    /// Uses `NSBatchInsertRequest` (BIR) to import a JSON dictionary into the Core Data store on a private queue.
    private func importPokemons(from pokemonList: [PokemonPreviewModel]) async throws {
        guard !pokemonList.isEmpty else { return }

        let taskContext = newTaskContext()
        // Add name and author to identify source of persistent history changes.
        taskContext.name = "importContext"
        taskContext.transactionAuthor = "importPokemons"

        /// - Tag: performAndWait
        try await taskContext.perform {
            // Execute the batch insert.
            /// - Tag: batchInsertRequest
            let batchInsertRequest = self.newBatchInsertRequest(with: pokemonList)
            
            if let fetchResult = try? taskContext.execute(batchInsertRequest),
               let batchInsertResult = fetchResult as? NSBatchInsertResult,
               let success = batchInsertResult.result as? Bool, success {
                return
            }
            self.logger.debug("Failed to execute batch insert request.")
            throw ApiError.batchInsertError
        }

        logger.debug("Successfully inserted data.")
    }
    
    func fetchPokemonDetails(id: String, name: String, update flag: Bool = false) async throws {
        do {
            let taskContext = newTaskContext()
            // Add name and author to identify source of persistent history changes.
            taskContext.name = "importDetailsContext"
            taskContext.transactionAuthor = "importPokemonDetails"
            
            let pokemonDetailsFetchRequest = PokemonDetails.fetchRequest()
            pokemonDetailsFetchRequest.predicate = NSPredicate(format: "id == %@", id)
            let returnedPokemonDetails = try taskContext.fetch(pokemonDetailsFetchRequest)
            if(flag == false && !returnedPokemonDetails.isEmpty) {
                return
            }
            try await PokeApi.apiManager.savePokemonImage(name, for: id, ofType: .details)
            
            // Decode pokemon details to a data model.
            let pokemonDetails = try await PokeApi.apiManager.getPokemonDetails(id)
            logger.debug("Received \(id) details.")
            
            // Import pokemon details into Core Data.
            logger.debug("Start importing data to the store...")
            try await importPokemonDetails(from: pokemonDetails, with: id, using: taskContext)
            logger.debug("Finished importing data.")
            
        } catch ApiError.wrongURL {
            print("Wrong url")
        } catch ApiError.invalidAddress {
            print("Wrong address")
        } catch ApiError.invalidServerResponse(let code) {
            await MainActor.run {
                detailsViewModel.alertItem = AlertItem(title: Text("Bad response"), message: Text("Error \(code)"), buttonTitle: Text("Go back"))
            }
        } catch {
            print("Invalid data")
        }
    }
    
    private func importPokemonDetails(from pokemonDetails: PokemonDetailsModel, with id: String, using taskContext: NSManagedObjectContext) async throws {

        try await taskContext.perform {
            do {
                let newPokemonDetails = PokemonDetails(context: taskContext)
                newPokemonDetails.name = pokemonDetails.name
                newPokemonDetails.id = pokemonDetails.id
                newPokemonDetails.height = pokemonDetails.height
                newPokemonDetails.weight = pokemonDetails.weight
                
                for stat in pokemonDetails.stats{
                    let newStat = Stat(context: taskContext)
                    newStat.id = pokemonDetails.id
                    newStat.name = stat.name
                    newStat.value = stat.value
                    newStat.detail = newPokemonDetails
                }
                
                try taskContext.save()
                return
            } catch {
                throw ApiError.batchInsertError
            }
        }

        logger.debug("Successfully inserted data.")
    }
    
    private func newBatchInsertRequest(with pokemonList: [PokemonPreviewModel]) -> NSBatchInsertRequest {
        var index = 0
        let total = pokemonList.count

        // Provide one dictionary at a time when the closure is called.
        let batchInsertRequest = NSBatchInsertRequest(entity: PokemonPreview.entity(), dictionaryHandler: { dictionary in
            guard index < total else { return true }
            let currentPokemon = pokemonList[index]
            Task{
                do {
                    try await PokeApi.apiManager.savePokemonImage(currentPokemon.name, for: currentPokemon.id, ofType: .preview)
                } catch {
                    self.logger.debug("Error saving image to disc.")
                }
            }
            dictionary.addEntries(from: currentPokemon.dictionaryValue)
            index += 1
            return false
        })
        
        return batchInsertRequest
    }
    
    func fetchPersistentHistory() async {
        do {
            try await fetchPersistentHistoryTransactionsAndChanges()
        } catch {
            logger.debug("\(error.localizedDescription)")
        }
    }
    
    private func fetchPersistentHistoryTransactionsAndChanges() async throws {
        let taskContext = newTaskContext()
        taskContext.name = "persistentHistoryContext"
        logger.debug("Start fetching persistent history changes from the store...")

        try await taskContext.perform {
            // Execute the persistent history change since the last transaction.
            /// - Tag: fetchHistory
            let changeRequest = NSPersistentHistoryChangeRequest.fetchHistory(after: self.lastToken)
            let historyResult = try taskContext.execute(changeRequest) as? NSPersistentHistoryResult
            if let history = historyResult?.result as? [NSPersistentHistoryTransaction],
               !history.isEmpty {
                self.mergePersistentHistoryChanges(from: history)
                return
            }

            self.logger.debug("No persistent history transactions found.")
            throw ApiError.persistentHistoryChangeError
        }

        logger.debug("Finished merging history changes.")
    }
    
    private func mergePersistentHistoryChanges(from history: [NSPersistentHistoryTransaction]) {
        self.logger.debug("Received \(history.count) persistent history transactions.")
        // Update view context with objectIDs from history change request.
        /// - Tag: mergeChanges
        let viewContext = container.viewContext
        viewContext.performAndWait {
            for transaction in history {
                viewContext.mergeChanges(fromContextDidSave: transaction.objectIDNotification())
                self.lastToken = transaction.token
            }
        }
    }
}
