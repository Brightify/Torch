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
        return self
    }
}

extension String: PropertyValueType {
    
    public func toAnyObject() -> AnyObject {
        return self
    }
}

extension NSData: PropertyValueType {
    
    public func toAnyObject() -> AnyObject {
        return self
    }
}