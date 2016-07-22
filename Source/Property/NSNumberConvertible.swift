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
}

extension Int: NSNumberConvertible {
    
    public init?(fromNSNumber number: NSNumber) {
        self = number.longValue
    }
    
    public func toNSNumber() -> NSNumber {
        return self as NSNumber
    }
}
