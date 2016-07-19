//
//  ApiDraft.swift
//  Torch
//
//  Created by Filip Dolnik on 19.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Foundation
import CoreData

public struct Torch {
    
    // TODO Difference?
    private let context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
    
    // TODO Default values
    public func load<T: TorchEntity>(type: T.Type, where predicate: Predicate = Predicate(), orderBy: SortDescriptor = SortDescriptor()) throws -> [T] {
        let request = NSFetchRequest(entityName: getEntityName(type))
        request.predicate = predicate.toNSPredicate()
        request.sortDescriptors = orderBy.toNSSortDescriptors()
        let objects = try context.executeFetchRequest(request) as! [NSManagedObject]
        return objects.map { T(fromManagedObject: $0) }
    }
    
    public func save<T: TorchEntity>(objects: T...) throws {
        try save(objects)
    }
    
    public func save<T: TorchEntity>(objects: [T]) throws {
        try objects.forEach {
            let managedObject = try getEntityManagedObject($0) ?? NSManagedObject()
            $0.updateManagedObject(managedObject)
            if !managedObject.inserted {
                context.insertObject(managedObject)
            }
        }
        try context.save()
    }
    
    public func delete<T: TorchEntity>(objects: T...) throws {
        try delete(objects)
    }
    
    public func delete<T: TorchEntity>(objects: [T]) throws {
        try objects.forEach {
            if let managedObject = try getEntityManagedObject($0) {
                context.deleteObject(managedObject)
            }
        }
        try context.save()
    }
    
    public func delete<T: TorchEntity>(type: T.Type, where predicate: Predicate) throws {
        let request = NSFetchRequest(entityName: getEntityName(type))
        request.predicate = predicate.toNSPredicate()
        (try context.executeFetchRequest(request) as! [NSManagedObject]).forEach {
            context.deleteObject($0)
        }
        try context.save()
    }
    
    public func deleteAll<T: TorchEntity>(type: T.Type) throws {
        // TODO Correct predicate
        try delete(type, where: Predicate())
    }
    
    private func getEntityName<T: TorchEntity>(type: T.Type) -> String {
        return String(type)
    }
    
    private func getEntityManagedObject<T: TorchEntity>(entity: T) throws -> NSManagedObject? {
        let request = NSFetchRequest(entityName: getEntityName(T))
        request.predicate = NSPredicate(format: "ID = %@", entity.ID)
        return (try context.executeFetchRequest(request) as? [NSManagedObject])?.first
    }
}

public struct UnsafeTorch {
    
    private let torch: Torch = Torch()
    
    // TODO Default values
    public func load<T: TorchEntity>(type: T.Type, where predicate: Predicate = Predicate(), orderBy: SortDescriptor = SortDescriptor()) -> [T] {
        return try! torch.load(type, where: predicate, orderBy: orderBy)
    }
    
    public func save<T: TorchEntity>(objects: T...) throws {
        save(objects)
    }
    
    // TODO Add proper error handling
    public func save<T: TorchEntity>(objects: [T]) {
        try! torch.save(objects)
    }
    
    public func delete<T: TorchEntity>(objects: T...) {
        delete(objects)
    }
    
    public func delete<T: TorchEntity>(objects: [T]) {
        try! torch.delete(objects)
    }
    
    public func delete<T: TorchEntity>(type: T.Type, where predicate: Predicate) {
        try! torch.delete(type, where: predicate)
    }
    
    public func deleteAll<T: TorchEntity>(type: T.Type) {
        try! torch.deleteAll(type)
    }
}

public protocol TorchEntity {
    
    var ID: Int { get }
    
    init(fromManagedObject: NSManagedObject)
    
    func updateManagedObject(managedObject: NSManagedObject)
}

public struct Predicate {
    
    func toNSPredicate() -> NSPredicate {
        return NSPredicate()
    }
}

public struct SortDescriptor {
    
    func toNSSortDescriptors() -> [NSSortDescriptor] {
        return []
    }
}












public struct Property<T> {
    public let name: String
}

public extension Property where T: Equatable {
    
    func equalTo(value: T) {
        
    }
}

public extension Property where T: Comparable {
    
    func greaterThan(value: T) {
        
    }
    
    func lessThan(value: T) {
        
    }
}

















