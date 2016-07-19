//
//  ApiDraft.swift
//  Torch
//
//  Created by Filip Dolnik on 19.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Foundation
import CoreData

public class Torch {
        
    private let context = NSManagedObjectContext(concurrencyType: .ConfinementConcurrencyType)
    
    private var uncommitedMetadata: [TorchMetadata] = []
    
    public init(persistentStoreCoordinator: NSPersistentStoreCoordinator) {
        context.persistentStoreCoordinator = persistentStoreCoordinator
    }
    
    // TODO Default values
    public func load<T: TorchEntity>(type: T.Type, where predicate: PredicateConvertible = PredicateConvertible(), orderBy: SortDescriptor = SortDescriptor()) throws -> [T] {
        let request = NSFetchRequest(entityName: getEntityName(type))
        request.predicate = predicate.toPredicate()
        request.sortDescriptors = orderBy.toSortDescriptors()
        let entities = try context.executeFetchRequest(request) as! [NSManagedObject]
        return entities.map { T(fromManagedObject: $0) }
    }
    
    public func save<T: TorchEntity>(inout entity: T) throws -> Torch {
        let managedObject: NSManagedObject
        if let existingManagedObject = try getEntityManagedObject(entity) {
            managedObject = existingManagedObject
        } else {
            let entityName = getEntityName(T)
            let description = NSEntityDescription.entityForName(entityName, inManagedObjectContext: context)
            // FIXME !
            managedObject = NSManagedObject(entity: description!, insertIntoManagedObjectContext: context)
            if entity.id == nil {
                entity.id = try getNextId(entityName)
            }
        }
        entity.updateManagedObject(managedObject)
        try updateLastAssignedId(entity)
        return self
    }
    
    public func delete<T: TorchEntity>(entities: T...) throws -> Torch {
        return try delete(entities)
    }
    
    public func delete<T: TorchEntity>(entities: [T]) throws -> Torch {
        try entities.forEach {
            if let managedObject = try getEntityManagedObject($0) {
                context.deleteObject(managedObject)
            }
        }
        return self
    }
    
    public func delete<T: TorchEntity>(type: T.Type, where predicate: PredicateConvertible) throws -> Torch {
        let request = NSFetchRequest(entityName: getEntityName(type))
        request.predicate = predicate.toPredicate()
        (try context.executeFetchRequest(request) as! [NSManagedObject]).forEach {
            context.deleteObject($0)
        }
        return self
    }
    
    public func deleteAll<T: TorchEntity>(type: T.Type) throws -> Torch {
        // TODO Correct PredicateConvertible
        return try delete(type, where: PredicateConvertible())
    }
    
    public func rollback() -> Torch {
        context.rollback()
        uncommitedMetadata = []
        return self
    }
    
    public func write(@noescape closure: () -> () = {}) throws -> Torch {
        closure()
        try context.save()
        uncommitedMetadata = []
        return self
    }
    
    
    private func getEntityName<T>(type: T.Type) -> String {
        return String(type)
    }
    
    private func getEntityManagedObject<T: TorchEntity>(entity: T) throws -> NSManagedObject? {
        if let id = entity.id {
            let entityName = getEntityName(T)
            let request = NSFetchRequest(entityName: entityName)
            request.predicate = NSPredicate(format: "id = %@", id as NSNumber)
            return (try context.executeFetchRequest(request) as! [NSManagedObject]).first
        } else {
            return nil
        }
    }
    
    private func getNextId(entityName: String) throws -> Int {
        return (try getMetadata(entityName)?.lastAssignedId as Int? ?? -1) + 1
    }
    
    private func updateLastAssignedId<T: TorchEntity>(entity: T) throws {
        if let id = entity.id {
            let entityType = getEntityName(T)
            if let metadata = try getMetadata(entityType) {
                metadata.lastAssignedId = max(metadata.lastAssignedId as Int, id)
            } else {
                let description = NSEntityDescription.entityForName(getEntityName(TorchMetadata.self), inManagedObjectContext: context)
                // FIXME !
                let metadata = TorchMetadata(entity: description!, insertIntoManagedObjectContext: context)
                metadata.entityType = entityType
                metadata.lastAssignedId = id
                uncommitedMetadata.append(metadata)
            }
        }
    }
    
    private func getMetadata(entityName: String) throws -> TorchMetadata? {
        let request = NSFetchRequest(entityName: getEntityName(TorchMetadata.self))
        request.predicate = NSPredicate(format: "entityType = %@", entityName)
        return (try context.executeFetchRequest(request) as? [TorchMetadata])?.first ?? uncommitedMetadata.filter { $0.entityType == entityName }.first
    }
}

public class UnsafeTorch {
    
    private let torch: Torch
    
    public init(persistentStoreCoordinator: NSPersistentStoreCoordinator) {
        torch = Torch(persistentStoreCoordinator: persistentStoreCoordinator)
    }
    
    // TODO Default values
    // TODO Add proper error handling
    public func load<T: TorchEntity>(type: T.Type, where predicate: PredicateConvertible = PredicateConvertible(), orderBy: SortDescriptor = SortDescriptor()) -> [T] {
        return try! torch.load(type, where: predicate, orderBy: orderBy)
    }
    
    public func save<T: TorchEntity>(inout entity: T) -> UnsafeTorch {
        try! torch.save(&entity)
        return self
    }

    public func delete<T: TorchEntity>(entities: T...) -> UnsafeTorch {
        delete(entities)
        return self
    }
    
    public func delete<T: TorchEntity>(entities: [T]) -> UnsafeTorch {
        try! torch.delete(entities)
        return self
    }
    
    public func delete<T: TorchEntity>(type: T.Type, where predicate: PredicateConvertible) -> UnsafeTorch {
        try! torch.delete(type, where: predicate)
        return self
    }
    
    public func deleteAll<T: TorchEntity>(type: T.Type) -> UnsafeTorch {
        try! torch.deleteAll(type)
        return self
    }
    
    public func rollback() -> UnsafeTorch {
        torch.rollback()
        return self
    }
    
    public func write(@noescape closure: () -> () = {}) -> UnsafeTorch {
        try! torch.write(closure)
        return self
    }
}

class TorchMetadata: NSManagedObject {
    
    @NSManaged var entityType: String
    @NSManaged var lastAssignedId: NSNumber
}

public protocol TorchEntity {
   
    var id: Int? { get set }
    
    init(fromManagedObject object: NSManagedObject)
    
    func updateManagedObject(object: NSManagedObject)
}

public struct PredicateConvertible {
    
    func toPredicate() -> NSPredicate {
        return NSPredicate(value: true)
    }
}

public struct SortDescriptor {
    
    func toSortDescriptors() -> [NSSortDescriptor] {
        return []
    }
}



/*


struct Property<PARENT: TorchEntity, T> {
    let name: String
    
    func equalTo(value: T) -> TypedFilter<T>
}

struct EqualToFilter<T>: PredicateConvertible {
    let property: Property<T>
    let value: T
    
    func asPredicate() -> String {
        return "\(property.name) = \(value)"
    }
}

extension Property where T: Equatable {
    func equalTo(value: T)
}

extension Property where T: Comparable {
    func greaterThan(value: T)
    func lessThan(value: T)
}




*/







