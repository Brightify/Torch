//
//  NSObjectConvertible.swift
//  Torch
//
//  Created by Filip Dolnik on 22.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Foundation

public protocol NSObjectConvertible: TorchPropertyType {
    
    init?(fromObject object: AnyObject)
    
    func toNSObject() -> NSObject
}

extension NSObjectConvertible {
    
    public func toNSObject() -> NSObject {
        return self as! NSObject
    }
}

extension String: NSObjectConvertible {
    
    public init?(fromObject object: AnyObject) {
        if let string = object as? String {
            self = string
        } else {
            return nil
        }
    }
}

extension Bool: NSObjectConvertible {
    
    public init?(fromObject object: AnyObject) {
        if let bool = object as? Bool {
            self = bool
        } else {
            return nil
        }
    }
}