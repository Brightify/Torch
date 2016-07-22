//
//  TorchMetadata.swift
//  Torch
//
//  Created by Filip Dolnik on 20.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import CoreData

@objc(TorchMetadata)
class TorchMetadata: NSManagedObject {

    static let NAME = "TorchSwift.TorchMetadata"
    
    @NSManaged var torchEntityName: String
    @NSManaged var lastAssignedId: NSNumber
    
    static func describeEntity(to registry: EntityRegistry) {
        let entity = NSEntityDescription()
        entity.name = NAME
        entity.managedObjectClassName = String(TorchMetadata)
        
        let name = NSAttributeDescription()
        name.name = "torchEntityName"
        name.attributeType = .StringAttributeType
        name.optional = false
        
        let id = NSAttributeDescription()
        id.name = "lastAssignedId"
        id.attributeType = .Integer64AttributeType
        id.optional = false

        entity.properties = [name, id]
        
        registry.describe(NAME, as: entity)
    }
}
