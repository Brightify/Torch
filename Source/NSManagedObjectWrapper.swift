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
    
    public func getValue<PARENT: TorchEntity, T: NSObjectConvertible>(property: TorchProperty<PARENT, T>) -> T {
        return T(fromObject: object.valueForKey(property.torchName)!)!
    }
    
    public func setValue<PARENT: TorchEntity, T: NSObjectConvertible>(value: T, for property: TorchProperty<PARENT, T>) {
        object.setValue(value.toNSObject(), forKey: property.torchName)
    }

    public func getValue<PARENT: TorchEntity, T: TorchPropertyOptionalType where T.Wrapped: NSObjectConvertible>(property: TorchProperty<PARENT, T>) -> T.Wrapped? {
        if let value = object.valueForKey(property.torchName) {
            return T.Wrapped(fromObject: value)!
        } else {
            return nil
        }
    }
    
    public func setValue<PARENT: TorchEntity, T: TorchPropertyOptionalType where T.Wrapped: NSObjectConvertible>(value: T, for property: TorchProperty<PARENT, T>) {
        object.setValue(value.value?.toNSObject() ?? NSNull(), forKey: property.torchName)
    }

    // TODO Add support for arrays

    public func getValue<PARENT: TorchEntity, T: TorchEntity>(property: TorchProperty<PARENT, T>) throws -> T {
        let managedObject = NSManagedObjectWrapper(object: object.valueForKey(property.torchName) as! NSManagedObject, database: database)
        return try T(fromManagedObject: managedObject)
    }
    
    public func setValue<PARENT: TorchEntity, T: TorchEntity>(inout value: T, for property: TorchProperty<PARENT, T>) throws {
        object.setValue(try database.getManagedObject(for: &value), forKey: property.torchName)
    }
    
    // TODO Add support for optional

    public func getValue<PARENT: TorchEntity, T: TorchPropertyArrayType where T.Element: TorchEntity>(property: TorchProperty<PARENT, T>) throws -> [T.Element] {
        return try (object.valueForKey(property.torchName) as! NSOrderedSet).map {
            try T.Element(fromManagedObject: NSManagedObjectWrapper(object: $0 as! NSManagedObject, database: database))
        } 
    }
    
    public func setValue<PARENT: TorchEntity, T: TorchPropertyArrayType where T.Element: TorchEntity>(inout values: T, for property: TorchProperty<PARENT, T>) throws {
        let set = NSMutableOrderedSet()
        for i in values.values.indices {
            set.addObject(try database.getManagedObject(for: &values[i]))
        }
        object.setValue(set, forKey: property.torchName)
    }
}