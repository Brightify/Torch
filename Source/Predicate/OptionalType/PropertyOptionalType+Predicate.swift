//
//  PropertyOptionalType+Predicate.swift
//  Torch
//
//  Created by Filip Dolnik on 31.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

public extension Property where T: PropertyOptionalType, T.Wrapped: PropertyValueType {
    
    public func equalTo(value: T) -> Predicate<PARENT> {
        return Predicate.singleValuePredicate(name, value: value.value?.toAnyObject(), operatorString: "==")
    }
    
    public func notEqualTo(value: T) -> Predicate<PARENT> {
        return Predicate.singleValuePredicate(name, value: value.value?.toAnyObject(), operatorString: "!=")
    }
}

public func == <P, T: PropertyOptionalType where T.Wrapped: PropertyValueType>(lhs: Property<P, T>, rhs: T) -> Predicate<P> {
    return lhs.equalTo(rhs)
}

public func != <P, T: PropertyOptionalType where T.Wrapped: PropertyValueType>(lhs: Property<P, T>, rhs: T) -> Predicate<P> {
    return lhs.notEqualTo(rhs)
}