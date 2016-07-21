//
//  PropertyRegistry.swift
//  Torch
//
//  Created by Filip Dolnik on 20.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import CoreData

public class PropertyRegistry {
    // TODO Add rest of types
    private static let typesArray: [(Any.Type, NSAttributeType)] = [
        (Int.self, NSAttributeType.Integer64AttributeType),
        (String.self, NSAttributeType.StringAttributeType),
        
        (Optional<Int>.self, NSAttributeType.Integer64AttributeType),
        (Optional<String>.self, NSAttributeType.StringAttributeType),
        ]
    
    private static let types: [ObjectIdentifier: NSAttributeType] = typesArray.reduce([:]) { acc, item in
        var mutableAccumulator = acc
        mutableAccumulator[ObjectIdentifier(item.0)] = item.1
        return mutableAccumulator
    }
    
    let entityRegistry: EntityRegistry
    
    public private(set) var registeredProperties: [String: NSPropertyDescription] = [:]
    
    public init(entityRegistry: EntityRegistry) {
        self.entityRegistry = entityRegistry
    }
    
    public func attribute<P: TypedTorchProperty>(property: P) {
        registerAttribute(property.name, type: P.ValueType.self, optional: false)
    }
    
    public func attribute<P: TypedTorchProperty where P.ValueType: OptionalType>(property: P) {
        registerAttribute(property.name, type: P.ValueType.WrappedType.self, optional: true)
    }
    
    public func relationship<P: TypedTorchProperty where P.ValueType: TorchEntity>(property: P) {
        registerRelationship(property.name, type: P.ValueType.self, optional: false, minCount: 1, maxCount: 1)
    }
    
    public func relationship<P: TypedTorchProperty where P.ValueType: OptionalType, P.ValueType.WrappedType: TorchEntity>(property: P) {
        registerRelationship(property.name, type: P.ValueType.WrappedType.self, optional: true, minCount: 1, maxCount: 1)
    }
    
    public func relationship<P: TypedTorchProperty where P.ValueType: SequenceType, P.ValueType.Generator.Element: TorchEntity>(property: P) {
        registerRelationship(property.name, type: P.ValueType.Generator.Element.self, optional: false, minCount: 0, maxCount: 0)
    }
    
    public func relationship<P: TypedTorchProperty where P.ValueType: OptionalType, P.ValueType.WrappedType: SequenceType, P.ValueType.WrappedType.Generator.Element: TorchEntity>(property: P) {
        registerRelationship(property.name, type: P.ValueType.WrappedType.Generator.Element.self, optional: true, minCount: 0, maxCount: 0)
    }
    
    private func registerAttribute<T>(name: String, type: T.Type, optional: Bool) {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = PropertyRegistry.types[ObjectIdentifier(type)] ?? NSAttributeType.UndefinedAttributeType
        attribute.optional = optional
        registeredProperties[name] = attribute
    }
    
    private func registerRelationship<T: TorchEntity>(name: String, type: T.Type, optional: Bool, minCount: Int, maxCount: Int) {
        let relationship = NSRelationshipDescription()
        relationship.name = name
        relationship.destinationEntity = entityRegistry.description(of: type)
        relationship.deleteRule = .NullifyDeleteRule
        relationship.optional = optional
        relationship.minCount = minCount
        relationship.maxCount = maxCount
        relationship.ordered = true
        registeredProperties[name] = relationship
    }
}
