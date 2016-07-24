//
//  PropertyArrayType.swift
//  Torch
//
//  Created by Filip Dolnik on 22.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

public protocol PropertyArrayType: PropertyType {
    
    associatedtype Element
    
    var values: [Element] { get }
    
    subscript(index: Int) -> Element { get set }
}

extension Array: PropertyArrayType {
    
    public var values: [Element] {
        return self
    }
}