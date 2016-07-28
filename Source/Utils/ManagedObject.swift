//
//  ManagedObject.swift
//  Torch
//
//  Created by Filip Dolnik on 21.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

// TODO Don't forget to escape characters

import GRDB

public class ManagedObject {

    private(set) var data: [String:DatabaseValue]
    // TODO Replace with closure
    private let database: Database

    init(data: [String:DatabaseValue], database: Database) {
        self.data = data
        self.database = database
    }

    public func getValue<PARENT: TorchEntity, T: PropertyValueType>(property: Property<PARENT, T>) -> T {
        return T.fromDatabaseValue(data[property.name]!)!
    }
    
    public func setValue<PARENT: TorchEntity, T: PropertyValueType>(value: T, for property: Property<PARENT, T>) {
        data[property.name] = value.databaseValue
    }

    public func getValue<PARENT: TorchEntity, T: PropertyOptionalType where T.Wrapped: PropertyValueType>(property: Property<PARENT, T>) -> T.Wrapped? {
        if let value = data[property.name] {
            return T.Wrapped.fromDatabaseValue(value)
        } else {
            return nil
        }
    }

    public func setValue<PARENT: TorchEntity, T: PropertyOptionalType where T.Wrapped: PropertyValueType>(value: T, for property: Property<PARENT, T>) {
        data[property.name] = value.value?.databaseValue
    }
/*
    public func getValue<PARENT: TorchEntity, T: PropertyArrayType where T.Element: PropertyValueType>(property: Property<PARENT, T>) -> [T.Element] {
        return (data[property.name] as! NSArray).map { T.Element.fromObject($0)! }
    }
*/
    /*public func setValue<PARENT: TorchEntity, T: PropertyArrayType where T.Element: PropertyValueType>(values: T, for property: Property<PARENT, T>) {

    }*/
/*
    public func getValue<PARENT: TorchEntity, T: PropertySetType where T.Element: NSObjectConvertible>(property: Property<PARENT, T>) -> Set<T.Element> {
        var result = Set<T.Element>()
        (object.valueForKey(property.torchName) as! NSSet).forEach { result.insert(T.Element.fromObject($0)!) }
        return result
    }

    public func setValue<PARENT: TorchEntity, T: PropertySetType where T.Element: NSObjectConvertible>(values: T, for property: Property<PARENT, T>) {
        let set = NSMutableSet()
        for value in values.values {
            set.addObject(value.toNSObject())
        }
        object.setValue(set, forKey: property.torchName)
    }

    public func getValue<PARENT: TorchEntity, T: TorchEntity>(property: Property<PARENT, T>) throws -> T {
        let managedObject = NSManagedObjectWrapper(object: object.valueForKey(property.torchName) as! NSManagedObject, database: database)
        return try T(fromManagedObject: managedObject)
    }
    
    public func setValue<PARENT: TorchEntity, T: TorchEntity>(inout value: T, for property: Property<PARENT, T>) throws {
        object.setValue(try database.getManagedObject(for: &value), forKey: property.torchName)
    }
    
    public func getValue<PARENT: TorchEntity, T: PropertyOptionalType where T.Wrapped: TorchEntity>(property: Property<PARENT, T>) throws -> T.Wrapped? {
        if let managedObject = object.valueForKey(property.torchName) as! NSManagedObject? {
            return try T.Wrapped(fromManagedObject: NSManagedObjectWrapper(object: managedObject , database: database))
        } else {
            return nil
        }
    }

    public func setValue<PARENT: TorchEntity, T: PropertyOptionalType where T.Wrapped: TorchEntity>(inout value: T, for property: Property<PARENT, T>) throws {
        if var mutableValue = value.value {
            let managedObject = try database.getManagedObject(for: &mutableValue)
            value.value = mutableValue
            object.setValue(managedObject, forKey: property.torchName)
        } else {
            object.setValue(nil, forKey: property.torchName)
        }
    }

    public func getValue<PARENT: TorchEntity, T: PropertyArrayType where T.Element: TorchEntity>(property: Property<PARENT, T>) throws -> [T.Element] {
        return try (object.valueForKey(property.torchName) as! NSMutableOrderedSet).map {
            try T.Element(fromManagedObject: NSManagedObjectWrapper(object: $0 as! NSManagedObject, database: database))
        }
    }

    public func setValue<PARENT: TorchEntity, T: PropertyArrayType where T.Element: TorchEntity>(inout values: T, for property: Property<PARENT, T>) throws {
        let set = NSMutableOrderedSet()
        for i in values.values.indices {
            set.addObject(try database.getManagedObject(for: &values[i]))
        }
        object.setValue(set, forKey: property.torchName)
    }*/
}