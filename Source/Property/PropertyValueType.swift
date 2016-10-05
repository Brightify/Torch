//
//  PropertyValueType.swift
//  Torch
//
//  Created by Filip Dolnik on 29.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Foundation

public protocol PropertyValueType: PropertyType {
    
    func toAnyObject() -> AnyObject
}

extension Bool: PropertyValueType {
    
    public func toAnyObject() -> AnyObject {
        return self as AnyObject
    }
}

extension String: PropertyValueType {
    
    public func toAnyObject() -> AnyObject {
        return self as AnyObject
    }
}

extension Data: PropertyValueType {
    
    public func toAnyObject() -> AnyObject {
        return self as AnyObject
    }
}
