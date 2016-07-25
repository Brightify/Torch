//
//  Database.swift
//  Torch
//
//  Created by Filip Dolnik on 20.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import CoreData

public class Database {
    public static let COLUMN_PREFIX = "torch_"

    internal let context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
    private var metadataMemoryStorage: [String: TorchMetadata] = [:]

    public init<S: SequenceType where S.Generator.Element == TorchEntity.Type>(store: StoreConfiguration, entities: S) throws {
        let managedObjectModel = NSManagedObjectModel()
        registerEntities(entities, managedObjectModel: managedObjectModel)

        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        try coordinator.addPersistentStoreWithType(store.storeType, configuration: store.configuration, URL: store.storeURL, options: store.options)
        context.persistentStoreCoordinator = coordinator

        let entityNames = Set(entities.map { $0.torch_name })
        for metadata in try createMetadata(entityNames) {
            metadataMemoryStorage[metadata.torchEntityName] = metadata
        }
    }
}

// MARK: - Actions
extension Database {
    internal func loadImpl<T: TorchEntity>(type: T.Type, predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) throws -> [T] {
        let request = NSFetchRequest(entityName: type.torch_name)
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        let entities = try context.executeFetchRequest(request) as! [NSManagedObject]
        return try entities.map { try T(fromManagedObject: NSManagedObjectWrapper(object: $0, database: self)) }
    }

    internal func deleteImpl<T: TorchEntity>(type: T.Type, predicate: NSPredicate?) throws {
        let request = NSFetchRequest(entityName: type.torch_name)
        request.predicate = predicate
        (try context.executeFetchRequest(request) as! [NSManagedObject]).forEach {
            context.deleteObject($0)
        }
    }

    internal func deleteImpl<T: TorchEntity>(entities: [T]) throws {
        try entities.forEach {
            if let managedObject = try loadManagedObject($0) {
                context.deleteObject(managedObject)
            }
        }
    }

    internal func createImpl<T: TorchEntity>(inout entity: T) throws {
        try getManagedObject(for: &entity)
    }
}

// MARK: CoreData bridging
extension Database {
    // Intentionally left `internal` because it is used in NSManagedObjectWrapper.
    internal func getManagedObject<T: TorchEntity>(inout for entity: T) throws -> NSManagedObject {
        let managedObject: NSManagedObject
        if entity.id == nil {
            managedObject = createManagedObject(T)
            entity.id = try getNextId(T)
        } else {
            managedObject = try loadManagedObject(entity) ?? createManagedObject(T)
        }
        try entity.torch_updateManagedObject(NSManagedObjectWrapper(object: managedObject, database: self))
        try updateLastAssignedId(entity)
        return managedObject
    }

    private func loadManagedObject<T: TorchEntity>(entity: T) throws -> NSManagedObject? {
        if let id = entity.id {
            let request = NSFetchRequest(entityName: T.torch_name)
            request.predicate = NSPredicate(format: "\(Database.COLUMN_PREFIX)id = %@", id as NSNumber)
            request.fetchLimit = 1
            request.returnsObjectsAsFaults = false
            request.includesSubentities = false
            request.includesPropertyValues = false
            return (try context.executeFetchRequest(request) as! [NSManagedObject]).first
        } else {
            return nil
        }
    }

    private func createManagedObject<T: TorchEntity>(entityType: T.Type) -> NSManagedObject {
        guard let description = NSEntityDescription.entityForName(T.torch_name, inManagedObjectContext: context) else {
            fatalError("Entity \(T.torch_name) is not registered!")
        }

        return NSManagedObject(entity: description, insertIntoManagedObjectContext: context)
    }

    private func getNextId<T: TorchEntity>(entityType: T.Type) throws -> Int {
        return try getMetadata(T.torch_name).lastAssignedId as Int + 1
    }

    private func updateLastAssignedId<T: TorchEntity>(entity: T) throws {
        guard let id = entity.id else { return }

        let metadata = try getMetadata(T.torch_name)
        metadata.lastAssignedId = max(metadata.lastAssignedId as Int, id)
    }

    private func getMetadata(entityName: String) throws -> TorchMetadata {
        guard let metadata = metadataMemoryStorage[entityName] else {
            fatalError("Metadata for entity \(entityName) not loaded! Make sure the entity is registered.")
        }
        return metadata
    }

    private func registerEntities<S: SequenceType where S.Generator.Element == TorchEntity.Type>(entities: S, managedObjectModel: NSManagedObjectModel) {
        let entityRegistry = EntityRegistry()
        TorchMetadata.describeEntity(to: entityRegistry)
        for registration in entities {
            registration.torch_describeEntity(to: entityRegistry)
        }
        let incompleteRegistrations = entityRegistry.registeredEntities.values.filter { $0.state == EntityRegistrationState.Partial }
        precondition(incompleteRegistrations.isEmpty,
                     "These entities were not properly registered!" +
                        incompleteRegistrations.map { $0.description.name ?? "nil" }.joinWithSeparator(", "))
        managedObjectModel.entities = entityRegistry.registeredEntities.values.map { $0.description }
    }

    private func createMetadata(entityNames: Set<String>) throws -> [TorchMetadata] {
        let request = NSFetchRequest(entityName: TorchMetadata.NAME)
        guard let description = NSEntityDescription.entityForName(TorchMetadata.NAME, inManagedObjectContext: context) else {
            fatalError("Entity \(TorchMetadata.NAME) is not registered!")
        }
        guard var allMetadata = try context.executeFetchRequest(request) as? [TorchMetadata] else {
            fatalError("Could not load metadata!")
        }

        for entityName in entityNames {
            if allMetadata.contains({ $0.torchEntityName == entityName }) {
                continue
            }

            let metadata = TorchMetadata(entity: description, insertIntoManagedObjectContext: context)
            metadata.torchEntityName = entityName
            metadata.lastAssignedId = -1
            allMetadata.append(metadata)
        }

        try write()

        return allMetadata
    }
}
