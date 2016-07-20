//
//  NSConvertible.swift
//  Torch
//
//  Created by Filip Dolnik on 20.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Foundation

public protocol NSObjectConvertible {
    func toNSObject() -> NSObject
}

public protocol NSNumberConvertible: NSObjectConvertible {
    func toNSNumber() -> NSNumber
}

extension NSNumberConvertible {
    public func toNSObject() -> NSObject {
        return toNSNumber()
    }
}

extension String: NSObjectConvertible {
    public func toNSObject() -> NSObject {
        return NSString(string: self)
    }
}

extension Int: NSNumberConvertible {
    public func toNSNumber() -> NSNumber {
        return NSNumber(integer: self)
    }
}