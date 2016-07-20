//
//  TorchEntity.swift
//  Torch
//
//  Created by Filip Dolnik on 20.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import CoreData

public protocol TorchEntityDescription {
    
    static var torch_name: String { get }
    
    static func torch_describe(to registry: EntityRegistry)
}

public protocol TorchEntity: TorchEntityDescription {
    
    var id: Int? { get set }
    
    init(fromManagedObject object: NSManagedObject, torch: Torch) throws
    
    mutating func torch_updateManagedObject(object: NSManagedObject, torch: Torch) throws
    
    static var torch_properties: [AnyProperty<Self>] { get }
}