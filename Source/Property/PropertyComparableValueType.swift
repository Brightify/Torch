//
//  PropertyComparableValueType.swift
//  Torch
//
//  Created by Filip Dolnik on 31.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Foundation

public protocol PropertyComparableValueType: PropertyValueType {
}

extension Int8: PropertyComparableValueType {
    
    public func toAnyObject() -> AnyObject {
        return NSNumber(char: self)
    }
}

extension Int16: PropertyComparableValueType {
    
    public func toAnyObject() -> AnyObject {
        return NSNumber(short: self)
    }
}

extension Int32: PropertyComparableValueType {
    
    public func toAnyObject() -> AnyObject {
        return NSNumber(int: self)
    }
}

extension Int64: PropertyComparableValueType {
    
    public func toAnyObject() -> AnyObject {
        return NSNumber(longLong: self)
    }
}

extension Int: PropertyComparableValueType {
    
    public func toAnyObject() -> AnyObject {
        return self
    }
}

extension Double: PropertyComparableValueType {
    
    public func toAnyObject() -> AnyObject {
        return self
    }
}

extension Float: PropertyComparableValueType {
    
    public func toAnyObject() -> AnyObject {
        return self
    }
}

extension NSDate: PropertyComparableValueType {
    
    public func toAnyObject() -> AnyObject {
        return self
    }
}