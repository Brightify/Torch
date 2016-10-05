//
//  PropertyValueTypeConvertible+Predicate.swift
//  Torch
//
//  Created by Filip Dolnik on 04.08.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

public extension Property where T: PropertyValueTypeConvertible {
    
    public func equalTo(_ value: T) -> Predicate<PARENT> {
        return Predicate.singleValuePredicate(name, value: value.toValue().toAnyObject(), operatorString: "==")
    }
    
    public func notEqualTo(_ value: T) -> Predicate<PARENT> {
        return Predicate.singleValuePredicate(name, value: value.toValue().toAnyObject(), operatorString: "!=")
    }
}

public func == <P, T: PropertyValueTypeConvertible>(lhs: Property<P, T>, rhs: T) -> Predicate<P> {
    return lhs.equalTo(rhs)
}

public func != <P, T: PropertyValueTypeConvertible>(lhs: Property<P, T>, rhs: T) -> Predicate<P> {
    return lhs.notEqualTo(rhs)
}
