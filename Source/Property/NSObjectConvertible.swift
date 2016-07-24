//
//  NSObjectConvertible.swift
//  Torch
//
//  Created by Filip Dolnik on 22.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Foundation

public protocol NSObjectConvertible: PropertyType {
    
    static func fromObject(object: AnyObject) -> Self?
    
    func toNSObject() -> NSObject
}

extension NSObjectConvertible { }

extension String: NSObjectConvertible {

    public static func fromObject(object: AnyObject) -> String? {
        if let string = object as? String {
            return string
        } else {
            return nil
        }
    }

    public func toNSObject() -> NSObject {
        return self
    }
}

extension Bool: NSObjectConvertible {

    public static func fromObject(object: AnyObject) -> Bool? {
        if let bool = object as? Bool {
            return bool
        } else {
            return nil
        }
    }

    public func toNSObject() -> NSObject {
        return self
    }
}