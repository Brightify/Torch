//
//  TorchEntity.swift
//  Torch
//
//  Created by Filip Dolnik on 20.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import CoreData

public protocol TorchEntity: TorchPropertyType {
    
    static var torch_name: String { get }
    
    var id: Int? { get set }
    
    init(fromManagedObject object: NSManagedObjectWrapper) throws
    
    mutating func torch_updateManagedObject(object: NSManagedObjectWrapper) throws
    
    static func torch_describeEntity(to registry: EntityRegistry)
    
    static func torch_describeProperties(to registry: PropertyRegistry)
}

/** 
 In the case of Generator not being able to describe your entity properly,
 you can implement this protocol instead and write the description yourself.
 Torch will then treat the type as any other entity.
 */
public protocol ManualTorchEntity: TorchEntity { }
