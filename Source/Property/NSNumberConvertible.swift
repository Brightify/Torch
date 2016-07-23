//
//  NSNumberConvertible.swift
//  Torch
//
//  Created by Filip Dolnik on 22.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Foundation

public protocol NSNumberConvertible: NSObjectConvertible {

    static func fromNSNumber(number: NSNumber) -> Self?

    func toNSNumber() -> NSNumber
}

extension NSNumberConvertible {

    public static func fromObject(object: AnyObject) -> Self? {
        if let number = object as? NSNumber {
            return fromNSNumber(number)
        } else {
            return nil
        }
    }
    
    public func toNSObject() -> NSObject {
        return toNSNumber()
    }
    
}

extension Int: NSNumberConvertible {

    public static func fromNSNumber(number: NSNumber) -> Int? {
        return number.integerValue
    }

    public func toNSNumber() -> NSNumber {
        return self
    }
}

extension Float: NSNumberConvertible {
    
    public static func fromNSNumber(number: NSNumber) -> Float? {
        return number.floatValue
    }

    public func toNSNumber() -> NSNumber {
        return self
    }
}

extension Double: NSNumberConvertible {
    
    public static func fromNSNumber(number: NSNumber) -> Double? {
        return number.doubleValue
    }

    public func toNSNumber() -> NSNumber {
        return self
    }
}
