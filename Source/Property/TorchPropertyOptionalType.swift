//
//  TorchPropertyOptionalType.swift
//  Torch
//
//  Created by Filip Dolnik on 22.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

public protocol TorchPropertyOptionalType: TorchPropertyType {
    
    associatedtype Wrapped
    
    var value: Wrapped? { get }
}

extension Optional: TorchPropertyOptionalType {
    
    public var value: Wrapped? {
        return self
    }
}