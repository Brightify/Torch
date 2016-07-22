//
//  TorchPropertyOptionalType.swift
//  Torch
//
//  Created by Filip Dolnik on 22.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

public protocol TorchPropertyOptionalType: TorchPropertyType {
    
    associatedtype Wrapped
    
    var value: Wrapped? { get set }
}

extension Optional: TorchPropertyOptionalType {
    
    public var value: Wrapped? {
        get {
            return self
        } set {
            self = newValue
        }
    }
}