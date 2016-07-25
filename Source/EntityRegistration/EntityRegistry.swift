//
//  EntityRegistry.swift
//  Torch
//
//  Created by Filip Dolnik on 20.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import CoreData

public enum EntityRegistrationState {
    case Partial
    case Complete
}

private func >= (lhs: EntityRegistrationState, rhs: EntityRegistrationState) -> Bool {
    switch (lhs, rhs) {
    case (.Complete, .Complete), (.Complete, .Partial), (.Partial, .Partial):
        return true
    default:
        return false
    }
}

struct EntityRegistration {
    var description: NSEntityDescription
    var state: EntityRegistrationState
}

public class EntityRegistry {
    private(set) var registeredEntities: [String: EntityRegistration] = [:]
    
    public func description(of entityType: TorchEntity.Type,
                               withState state: EntityRegistrationState = .Complete) -> NSEntityDescription {
        if let registration = registeredEntities[entityType.torch_name] where registration.state >= state {
            return registration.description
        }

        let entity = NSEntityDescription()
        entity.name = entityType.torch_name
        registeredEntities[entityType.torch_name] = EntityRegistration(description: entity, state: .Partial)

        let propertyRegistry = PropertyRegistry(entityRegistry: self)
        entityType.torch_describeProperties(to: propertyRegistry)
        entity.properties = propertyRegistry.registeredProperties
        entity.properties.forEach {
            if $0.name == Database.getColumnName("id") {
                $0.indexed = true
            }
        }

        registeredEntities[entityType.torch_name] = EntityRegistration(description: entity, state: .Complete)

        return entity
    }
    
    func describe(entityName: String, as description: NSEntityDescription) {
        if registeredEntities[entityName] == nil {
            registeredEntities[entityName] = EntityRegistration(description: description, state: .Complete)
        }
    }
}
