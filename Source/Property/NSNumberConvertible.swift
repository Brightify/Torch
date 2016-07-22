//
//  NSNumberConvertible.swift
//  Torch
//
//  Created by Filip Dolnik on 22.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Foundation

public protocol NSNumberConvertible: NSObjectConvertible {
    
    init?(fromNSNumber number: NSNumber)
    
    func toNSNumber() -> NSNumber
}

extension NSNumberConvertible {
    
    public init?(fromObject object: AnyObject) {
        if let number = object as? NSNumber {
            self.init(fromNSNumber: number)
        } else {
            return nil
        }
    }
    
    public func toNSObject() -> NSObject {
        return toNSNumber()
    }
    
    public func toNSNumber() -> NSNumber {
        return self as! NSNumber
    }
}

extension Int: NSNumberConvertible {
    
    public init?(fromNSNumber number: NSNumber) {
        self = number.longValue
    }
}

extension Float: NSNumberConvertible {
    
    public init?(fromNSNumber number: NSNumber) {
        self = number.floatValue
    }
}

extension Double: NSNumberConvertible {
    
    public init?(fromNSNumber number: NSNumber) {
        self = number.doubleValue
    }
}
