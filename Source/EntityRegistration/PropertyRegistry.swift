//
//  PropertyRegistry.swift
//  Torch
//
//  Created by Filip Dolnik on 20.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

public class PropertyRegistry {
    
    private(set) var registeredProperties: [String] = []
    
    public func description<PARENT: TorchEntity, T: PropertyValueType>(of property: Property<PARENT, T>) {
        register(property.name, type: T.databaseValueType)
    }
    
    public func description<PARENT: TorchEntity, T: PropertyArrayType>(of property: Property<PARENT, T>) {
        register(property.name, type: .Blob)
    }
    
    public func description<PARENT: TorchEntity, T: PropertySetType where T.Element: PropertyValueType>(of property: Property<PARENT, T>) {
        register(property.name, type: .Blob)
    }
    
    public func description<PARENT: TorchEntity, T: PropertyOptionalType where T.Wrapped: PropertyValueType>(of property: Property<PARENT, T>) {
        register(property.name, type: .Blob)
    }
    
    public func description<PARENT: TorchEntity, T: TorchEntity>(of property: Property<PARENT, T>) {
        register(property.name, type: .Int)
    }
    
    private func register(name: String, type: DatabaseValueType) {
        if name == "id" {
            registeredProperties.append("id INTEGER PRIMARY KEY")
        } else {
            registeredProperties.append("\(name) \(type.rawValue)")
        }
    }
}
