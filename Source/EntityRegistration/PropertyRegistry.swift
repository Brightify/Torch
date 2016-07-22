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
        (String.self, NSAttributeType.StringAttributeType)
        ]
    
    private static let types: [ObjectIdentifier: NSAttributeType] = typesArray.reduce([:]) { acc, item in
        var mutableAccumulator = acc
        mutableAccumulator[ObjectIdentifier(item.0)] = item.1
        return mutableAccumulator
    }
    
    private let entityRegistry: EntityRegistry
    
    private(set) var registeredProperties: [NSPropertyDescription] = []
    
    init(entityRegistry: EntityRegistry) {
        self.entityRegistry = entityRegistry
    }
    
    public func description<PARENT: TorchEntity, T: TorchPropertyType>(of property: TorchProperty<PARENT, T>) {
        fatalError("Unsupported type \(String(T)). Consider extending it with `NSObjectConvertible` or add new overload for this method with correct implementation.")
    }
    
    public func description<PARENT: TorchEntity, T: NSObjectConvertible>(of property: TorchProperty<PARENT, T>) {
        registerAttribute(property.torchName, type: T.self, optional: false)
    }
    
    // TODO maybe conversion needed
    public func description<PARENT: TorchEntity, T: TorchPropertyArrayType where T.Element: NSObjectConvertible>(of property: TorchProperty<PARENT, T>) {
        registerAttribute(property.torchName, type: T.self, optional: false, isArray: true)
    }
    
    public func description<PARENT: TorchEntity, T: TorchPropertyOptionalType where T.Wrapped: NSObjectConvertible>(of property: TorchProperty<PARENT, T>) {
        registerAttribute(property.torchName, type: T.Wrapped.self, optional: true)
    }
    
    public func description<PARENT: TorchEntity, T: TorchEntity>(of property: TorchProperty<PARENT, T>) {
        registerRelationship(property.torchName, type: T.self, optional: false, minCount: 1, maxCount: 1)
    }
    
    public func description<PARENT: TorchEntity, T: TorchPropertyArrayType where T.Element: TorchEntity>(of property: TorchProperty<PARENT, T>) {
        registerRelationship(property.torchName, type: T.Element.self, optional: false, minCount: 0, maxCount: 0)
    }
    
    public func description<PARENT: TorchEntity, T: TorchPropertyOptionalType where T.Wrapped: TorchEntity>(of property: TorchProperty<PARENT, T>) {
        registerRelationship(property.torchName, type: T.Wrapped.self, optional: true, minCount: 1, maxCount: 1)
    }
    
    private func registerAttribute<T>(name: String, type: T.Type, optional: Bool, isArray: Bool = false) {
        let attributeType: NSAttributeType
        if isArray {
            attributeType = .TransformableAttributeType
        } else {
            attributeType = PropertyRegistry.types[ObjectIdentifier(T)] ?? .TransformableAttributeType
        }
        
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = attributeType
        attribute.optional = optional
        registeredProperties.append(attribute)
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
        registeredProperties.append(relationship)
    }
}
