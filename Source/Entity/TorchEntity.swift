//
//  TorchEntity.swift
//  Torch
//
//  Created by Filip Dolnik on 20.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

public protocol TorchEntity: PropertyType {
    static var torch_name: String { get }

    var id: Int? { get set }

    init(fromManagedObject object: ManagedObject) throws

    mutating func torch_updateManagedObject(object: ManagedObject) throws

    static func torch_describeProperties(to registry: PropertyRegistry)
}
