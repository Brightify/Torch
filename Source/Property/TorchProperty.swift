//
//  TorchProperty.swift
//  Torch
//
//  Created by Filip Dolnik on 20.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import CoreData

public protocol TorchProperty {
    associatedtype ParentType: TorchEntity
    
    var name: String { get }
    
    func describe(to registry: PropertyRegistry)
}

extension TorchProperty {
    var torchName: String {
        return Database.COLUMN_PREFIX + name
    }
    
    public func typeErased() -> AnyProperty<ParentType> {
        return AnyProperty(name: name, describeFunction: describe)
    }
}

public protocol TypedTorchProperty: TorchProperty {
    associatedtype ValueType
}

public struct AnyProperty<PARENT: TorchEntity>: TorchProperty {
    public typealias ParentType = PARENT
    
    public let name: String
    public let describeFunction: (PropertyRegistry) -> Void
    
    public func describe(to registry: PropertyRegistry) {
        describeFunction(registry)
    }
}

public struct ScalarProperty<PARENT: TorchEntity, T>: TypedTorchProperty {
    public typealias ParentType = PARENT
    public typealias ValueType = T
    
    public let name: String
    
    public init(name: String) {
        self.name = name
    }
    
    public func describe(to registry: PropertyRegistry) {
        registry.attribute(self)
    }
}

public struct ToOneRelationProperty<PARENT: TorchEntity, T: TorchEntity>: TypedTorchProperty {
    public typealias ParentType = PARENT
    public typealias ValueType = T
    
    public let name: String
    
    public init(name: String) {
        self.name = name
    }
    
    public func describe(to registry: PropertyRegistry) {
        registry.relationship(self)
    }
}

public struct ToManyRelationProperty<PARENT: TorchEntity, T: SequenceType where T.Generator.Element: TorchEntity>: TypedTorchProperty {
    public typealias ParentType = PARENT
    public typealias ValueType = T
    
    public let name: String
    
    public init(name: String) {
        self.name = name
    }
    
    public func describe(to registry: PropertyRegistry) {
        registry.relationship(self)
    }
}