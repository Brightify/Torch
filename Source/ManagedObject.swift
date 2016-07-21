//
//  ManagedObject.swift
//  Torch
//
//  Created by Filip Dolnik on 21.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import CoreData

public struct ManagedObject {
    
    private let object: NSManagedObject
    private let database: Database
    
    init(object: NSManagedObject, database: Database) {
        self.database = database
        self.object = object
    }
    
    public func getValue<T>(key: String) -> T {
        return object.valueForKey(key) as! T
    }
    
    public func setValue<T: NSObject>(value: T?, _ key: String) {
        object.setValue(value, forKey: key)
    }

    public func getValue<T: TorchEntity>(key: String) throws -> T {
        let managedObject = ManagedObject(object: object.valueForKey(key) as! NSManagedObject, database: database)
        return try T.init(fromManagedObject: managedObject)
    }
    
    public func setValue<T: TorchEntity>(inout value: T, _ key: String) throws {
        object.setValue(try database.getManagedObject(for: &value), forKey: key)
    }
    
    public func getValue<T: TorchEntity>(key: String) throws -> [T] {
        return try (object.valueForKey(key) as! NSOrderedSet).map { try T(fromManagedObject: ManagedObject(object: $0 as! NSManagedObject, database: database)) }
    }
    
    public func setValue<T: TorchEntity>(inout values: [T], _ key: String) throws {
        let set = NSMutableOrderedSet()
        for i in values.indices {
            set.addObject(try database.getManagedObject(for: &values[i]))
        }
        object.setValue(set, forKey: key)
    }
}