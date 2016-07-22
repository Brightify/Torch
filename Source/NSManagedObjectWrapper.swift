//
//  NSManagedObjectWrapper.swift
//  Torch
//
//  Created by Filip Dolnik on 21.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import CoreData

public struct NSManagedObjectWrapper {
    
    private let object: NSManagedObject
    private let database: Database
    
    init(object: NSManagedObject, database: Database) {
        self.database = database
        self.object = object
    }
    
    public func getValue<P: TypedTorchProperty>(property: P) -> P.ValueType {
        return object.valueForKey(property.torchName) as! P.ValueType
    }
    
    public func setValue<P: TypedTorchProperty>(value: P.ValueType, for property: P) {
        guard let value = value as? NSObject else {
            fatalError("Cannot convert type \(P.ValueType.self) to NSObject!")
        }
        object.setValue(value, forKey: property.torchName)
    }

    public func getValue<P: TypedTorchProperty where P.ValueType: TorchEntity>(property: P) throws -> P.ValueType {
        let managedObject = NSManagedObjectWrapper(object: object.valueForKey(property.torchName) as! NSManagedObject, database: database)
        return try P.ValueType(fromManagedObject: managedObject)
    }
    
    public func setValue<P: TypedTorchProperty where P.ValueType: TorchEntity>(inout value: P.ValueType, for property: P) throws {
        object.setValue(try database.getManagedObject(for: &value), forKey: property.torchName)
    }
    
    public func getValue<T: TorchEntity, P: TypedTorchProperty where P.ValueType == Array<T>>(property: P) throws -> P.ValueType {
        return try (object.valueForKey(property.torchName) as! NSOrderedSet).map {
            try P.ValueType.Generator.Element(fromManagedObject: NSManagedObjectWrapper(object: $0 as! NSManagedObject, database: database))
        } 
    }
    
    public func setValue<T: TorchEntity, P: TypedTorchProperty where P.ValueType == Array<T>>(inout values: P.ValueType, for property: P) throws {
        let set = NSMutableOrderedSet()
        for i in values.indices {
            set.addObject(try database.getManagedObject(for: &values[i]))
        }
        object.setValue(set, forKey: property.torchName)
    }
}