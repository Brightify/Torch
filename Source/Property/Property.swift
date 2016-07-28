//
//  Property.swift
//  Torch
//
//  Created by Filip Dolnik on 20.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import GRDB

public struct Property<PARENT: TorchEntity, T: PropertyType> {
    
    public let name: String
    
    public init(name: String) {
        self.name = name
    }
}