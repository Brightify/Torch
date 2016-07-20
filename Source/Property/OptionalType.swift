//
//  OptionalType.swift
//  Torch
//
//  Created by Filip Dolnik on 20.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

public protocol OptionalType {
    associatedtype WrappedType
    
    var value: WrappedType? { get }
}

extension Optional: OptionalType {
    public typealias WrappedType = Wrapped
    
    public var value: Wrapped? {
        return self
    }
}