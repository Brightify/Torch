//
//  PropertyValueType+Predicate.swift
//  Torch
//
//  Created by Filip Dolnik on 31.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

public extension Property where T: PropertyValueType {
    
    func equalTo(_ value: T) -> Predicate<PARENT> {
        return Predicate.singleValuePredicate(name, value: value.toAnyObject(), operatorString: "==")
    }
    
    func notEqualTo(_ value: T) -> Predicate<PARENT> {
        return Predicate.singleValuePredicate(name, value: value.toAnyObject(), operatorString: "!=")
    }
}

public func == <P, T: PropertyValueType>(lhs: Property<P, T>, rhs: T) -> Predicate<P> {
    return lhs.equalTo(rhs)
}

public func != <P, T: PropertyValueType>(lhs: Property<P, T>, rhs: T) -> Predicate<P> {
    return lhs.notEqualTo(rhs)
}
