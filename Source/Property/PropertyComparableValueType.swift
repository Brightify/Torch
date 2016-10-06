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
        return NSNumber(value: self as Int8)
    }
}

extension Int16: PropertyComparableValueType {
    
    public func toAnyObject() -> AnyObject {
        return NSNumber(value: self as Int16)
    }
}

extension Int32: PropertyComparableValueType {
    
    public func toAnyObject() -> AnyObject {
        return NSNumber(value: self as Int32)
    }
}

extension Int64: PropertyComparableValueType {
    
    public func toAnyObject() -> AnyObject {
        return NSNumber(value: self as Int64)
    }
}

extension Int: PropertyComparableValueType {
    
    public func toAnyObject() -> AnyObject {
        return self as AnyObject
    }
}

extension Double: PropertyComparableValueType {
    
    public func toAnyObject() -> AnyObject {
        return self as AnyObject
    }
}

extension Float: PropertyComparableValueType {
    
    public func toAnyObject() -> AnyObject {
        return self as AnyObject
    }
}

extension Date: PropertyComparableValueType {
    
    public func toAnyObject() -> AnyObject {
        return self as AnyObject
    }
}

extension NSDate: PropertyComparableValueType {

    public func toAnyObject() -> AnyObject {
        return self as AnyObject
    }
}
