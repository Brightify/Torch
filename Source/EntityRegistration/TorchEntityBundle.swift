//
//  TorchEntityBundle.swift
//  Torch
//
//  Created by Tadeáš Kříž on 23/07/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

/// Bundle of entity types to register into Database.
public protocol TorchEntityBundle {
    var entityTypes: [TorchEntity.Type] { get }
}
