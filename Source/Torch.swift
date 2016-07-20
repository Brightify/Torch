//
//  Torch.swift
//  Torch
//
//  Created by Filip Dolnik on 20.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import CoreData

public class Torch {
    private let context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
    
    public convenience init(store: StoreConfiguration, entities: TorchEntityDescription.Type...) throws {
        try self.init(store: store, entities: entities)
    }
    
    public init(store: StoreConfiguration, entities: [TorchEntityDescription.Type]) throws {
        let managedObjectModel = NSManagedObjectModel()
        registerEntities(entities, managedObjectModel: managedObjectModel)
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        try coordinator.addPersistentStoreWithType(store.storeType, configuration: store.configuration, URL: store.storeURL, options: store.options)
        context.persistentStoreCoordinator = coordinator
        
        try registerMetadata(entities.map { $0.torch_name })
    }
    
    public func load<T: TorchEntity>(type: T.Type) throws -> [T] {
        return try load(type, where: BoolPredicate(value: true))
    }
    
    // TODO Default values
    public func load<T: TorchEntity, P: PredicateConvertible where T == P.ParentType>(type: T.Type, where predicate: P, orderBy: SortDescriptor = SortDescriptor()) throws -> [T] {
        let request = NSFetchRequest(entityName: type.torch_name)
        request.predicate = predicate.toPredicate()
        request.sortDescriptors = orderBy.toSortDescriptors()
        let entities = try context.executeFetchRequest(request) as! [NSManagedObject]
        return try entities.map { try T(fromManagedObject: $0, torch: self) }
    }
    
    public func save<T: TorchEntity>(inout entity: T) throws -> Torch {
        try getManagedObject(for: &entity)
        return self
    }
    
    public func delete<T: TorchEntity>(entities: T...) throws -> Torch {
        return try delete(entities)
    }
    
    public func delete<T: TorchEntity>(entities: [T]) throws -> Torch {
        try entities.forEach {
            if let managedObject = try loadManagedObject($0) {
                context.deleteObject(managedObject)
            }
        }
        return self
    }
    
    public func delete<T: TorchEntity, P: PredicateConvertible where T == P.ParentType>(type: T.Type, where predicate: P) throws -> Torch {
        let request = NSFetchRequest(entityName: type.torch_name)
        request.predicate = predicate.toPredicate()
        (try context.executeFetchRequest(request) as! [NSManagedObject]).forEach {
            context.deleteObject($0)
        }
        return self
    }
    
    public func deleteAll<T: TorchEntity>(type: T.Type) throws -> Torch {
        return try delete(type, where: BoolPredicate(value: true))
    }
    
    public func rollback() -> Torch {
        context.rollback()
        return self
    }
    
    public func write(@noescape closure: () throws -> Void = {}) throws -> Torch {
        try closure()
        try context.save()
        return self
    }
    
    // Public because needed in generated code.
    public func getManagedObject<T: TorchEntity>(inout for entity: T) throws -> NSManagedObject {
        if entity.id == nil {
            entity.id = try getNextId(T)
        }
        let managedObject = try loadManagedObject(entity) ?? createManagedObject(T)
        try entity.torch_updateManagedObject(managedObject, torch: self)
        try updateLastAssignedId(entity)
        return managedObject
    }
    
    private func loadManagedObject<T: TorchEntity>(entity: T) throws -> NSManagedObject? {
        if let id = entity.id {
            let request = NSFetchRequest(entityName: T.torch_name)
            request.predicate = NSPredicate(format: "id = %@", id as NSNumber)
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
        let request = NSFetchRequest(entityName: TorchMetadata.torch_name)
        request.predicate = NSPredicate(format: "entityName = %@", entityName)
        guard let metadata = (try context.executeFetchRequest(request) as? [TorchMetadata])?.first else {
            fatalError("Could not load metadata for entity \(entityName)!")
        }
        return metadata
    }
    
    private func registerEntities(entities: [TorchEntityDescription.Type], managedObjectModel: NSManagedObjectModel) {
        let entityRegistry = EntityRegistry()
        TorchMetadata.torch_describe(to: entityRegistry)
        for registration in entities {
            registration.torch_describe(to: entityRegistry)
        }
        managedObjectModel.entities = Array(entityRegistry.registeredEntities.values)
    }
    
    private func registerMetadata(entityNames: [String]) throws {
        let request = NSFetchRequest(entityName: TorchMetadata.torch_name)
        guard let description = NSEntityDescription.entityForName(TorchMetadata.torch_name, inManagedObjectContext: context) else {
            fatalError("Entity \(TorchMetadata.torch_name) is not registered!")
        }
        guard var allMetadata = try context.executeFetchRequest(request) as? [TorchMetadata] else {
            fatalError("Could not load metadata!")
        }

        for entityName in entityNames {
            if allMetadata.contains({ $0.entityName == entityName }) {
                continue
            }

            let metadata = TorchMetadata(entity: description, insertIntoManagedObjectContext: context)
            metadata.entityName = entityName
            metadata.lastAssignedId = -1
            allMetadata.append(metadata)
        }
        
        try write()
    }
}
