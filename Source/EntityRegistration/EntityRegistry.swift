//
//  EntityRegistry.swift
//  Torch
//
//  Created by Filip Dolnik on 20.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import CoreData

public class EntityRegistry {
    private(set) var registeredEntities: [String: NSEntityDescription] = [:]
    
    public func description<E: TorchEntity>(of entityType: E.Type) -> NSEntityDescription {
        if let registeredEntity = registeredEntities[entityType.torch_name] {
            return registeredEntity
        }
        
        let entity = NSEntityDescription()
        entity.name = entityType.torch_name

        let propertyRegistry = PropertyRegistry(entityRegistry: self)
        for property in entityType.torch_properties {
            property.describe(to: propertyRegistry)
        }
        entity.properties = propertyRegistry.registeredProperties
        
        describe(entityType.torch_name, as: entity)
        return entity
    }
    
    func describe(entityName: String, as description: NSEntityDescription) {
        if registeredEntities[entityName] == nil {
            registeredEntities[entityName] = description
        }
    }
}
