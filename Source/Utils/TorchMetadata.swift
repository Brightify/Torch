//
//  TorchMetadata.swift
//  Torch
//
//  Created by Filip Dolnik on 20.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import CoreData

@objc(TorchMetadata)
class TorchMetadata: NSManagedObject, TorchEntityDescription {

    static var torch_name: String {
        return "TorchSwift.TorchMetadata"
    }
    
    @NSManaged var entityName: String
    @NSManaged var lastAssignedId: NSNumber
    
    static func torch_describe(to registry: EntityRegistry) {
        let entity = NSEntityDescription()
        entity.name = torch_name
        entity.managedObjectClassName = String(TorchMetadata)
        
        let name = NSAttributeDescription()
        name.name = "entityName"
        name.attributeType = .StringAttributeType
        name.optional = false
        
        let id = NSAttributeDescription()
        id.name = "lastAssignedId"
        id.attributeType = .Integer64AttributeType
        id.optional = false

        entity.properties = [name, id]
        
        registry.describe(torch_name, as: entity)
    }
}
