//
//  Database.swift
//  Torch
//
//  Created by Filip Dolnik on 20.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import CoreData

public class Database {
    
    static let COLUMN_PREFIX = "torch_"
    
    private let context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
    
    public convenience init(store: StoreConfiguration, entities: TorchEntity.Type...) throws {
        try self.init(store: store, entities: entities)
    }
    
    public init(store: StoreConfiguration, entities: [TorchEntity.Type]) throws {
        let managedObjectModel = NSManagedObjectModel()
        registerEntities(entities, managedObjectModel: managedObjectModel)
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        try coordinator.addPersistentStoreWithType(store.storeType, configuration: store.configuration, URL: store.storeURL, options: store.options)
        context.persistentStoreCoordinator = coordinator
        
        try createMetadata(entities.map { $0.torch_name })
    }
    
    public func load<T: TorchEntity>(type: T.Type) throws -> [T] {
        return try load(type, where: TorchPredicate(value: true))
    }
    
    // TODO Default values
    public func load<T: TorchEntity>(type: T.Type, where predicate: TorchPredicate<T>, orderBy: SortDescriptor = SortDescriptor()) throws -> [T] {
        let request = NSFetchRequest(entityName: type.torch_name)
        request.predicate = predicate.toPredicate()
        request.sortDescriptors = orderBy.toSortDescriptors()
        let entities = try context.executeFetchRequest(request) as! [NSManagedObject]
        return try entities.map { try T(fromManagedObject: NSManagedObjectWrapper(object: $0, database: self)) }
    }
    
    /**
        Saves object current state to database. Creates new object in database if necessery (id doesn`t exist yet or is nil).
        If object doesn`t have id it is not possible to use it afterwards (next invocation of save will create new object).
        If you do want to continue using the same object without loading it from database you can use `create` instead.
    */
    public func save<T: TorchEntity>(entities: T...) throws -> Database {
        return try save(entities)
    }
    
    public func save<T: TorchEntity>(entities: [T]) throws -> Database {
        var mutableEntities = entities
        try create(&mutableEntities)
        return self
    }
    
    /**
        Same as `save` except it is possible to set entity new id. This allows to use the same object after it was created. If object has id this method acts as `save`.
     */
    public func create<T: TorchEntity>(inout entity: T) throws -> Database {
        try getManagedObject(for: &entity)
        return self
    }
    
    public func create<T: TorchEntity>(inout entities: [T]) throws -> Database {
        for i in entities.indices {
            try create(&entities[i])
        }
        return self
    }
    
    public func delete<T: TorchEntity>(entities: T...) throws -> Database {
        return try delete(entities)
    }
    
    public func delete<T: TorchEntity>(entities: [T]) throws -> Database {
        try entities.forEach {
            if let managedObject = try loadManagedObject($0) {
                context.deleteObject(managedObject)
            }
        }
        return self
    }
    
    public func delete<T: TorchEntity>(type: T.Type, where predicate: TorchPredicate<T>) throws -> Database {
        let request = NSFetchRequest(entityName: type.torch_name)
        request.predicate = predicate.toPredicate()
        (try context.executeFetchRequest(request) as! [NSManagedObject]).forEach {
            context.deleteObject($0)
        }
        return self
    }
    
    public func deleteAll<T: TorchEntity>(type: T.Type) throws -> Database {
        return try delete(type, where: TorchPredicate(value: true))
    }
    
    public func rollback() -> Database {
        context.rollback()
        return self
    }
    
    public func write(@noescape closure: () throws -> Void = {}) throws -> Database {
        try closure()
        try context.save()
        return self
    }
    
    func getManagedObject<T: TorchEntity>(inout for entity: T) throws -> NSManagedObject {
        if entity.id == nil {
            entity.id = try getNextId(T)
        }
        let managedObject = try loadManagedObject(entity) ?? createManagedObject(T)
        try entity.torch_updateManagedObject(NSManagedObjectWrapper(object: managedObject, database: self))
        try updateLastAssignedId(entity)
        return managedObject
    }
    
    private func loadManagedObject<T: TorchEntity>(entity: T) throws -> NSManagedObject? {
        if let id = entity.id {
            let request = NSFetchRequest(entityName: T.torch_name)
            request.predicate = NSPredicate(format: "\(Database.COLUMN_PREFIX)id = %@", id as NSNumber)
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
        let request = NSFetchRequest(entityName: TorchMetadata.NAME)
        request.predicate = NSPredicate(format: "torchEntityName = %@", entityName)
        guard let metadata = (try context.executeFetchRequest(request) as? [TorchMetadata])?.first else {
            fatalError("Could not load metadata for entity \(entityName)!")
        }
        return metadata
    }
    
    private func registerEntities(entities: [TorchEntity.Type], managedObjectModel: NSManagedObjectModel) {
        let entityRegistry = EntityRegistry()
        TorchMetadata.describeEntity(to: entityRegistry)
        for registration in entities {
            registration.torch_describeEntity(to: entityRegistry)
        }
        managedObjectModel.entities = Array(entityRegistry.registeredEntities.values)
    }
    
    private func createMetadata(entityNames: [String]) throws {
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
    }
}
