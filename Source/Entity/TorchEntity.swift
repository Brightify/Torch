//
//  TorchEntity.swift
//  Torch
//
//  Created by Filip Dolnik on 20.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import RealmSwift

public protocol TorchEntity: PropertyType {
    associatedtype ManagedObjectType: Object, ManagedObject

    var id: Int? { get set }

    init(fromManagedObject object: ManagedObjectType)

    mutating func torch_updateManagedObject(object: ManagedObjectType, database: Database)
    
    static func torch_deleteValueTypeWrappers(object: ManagedObjectType, @noescape deleteFunction: (RealmSwift.Object) -> Void)
}
