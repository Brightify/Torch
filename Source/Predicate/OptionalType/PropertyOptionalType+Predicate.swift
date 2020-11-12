//
//  PropertyOptionalType+Predicate.swift
//  Torch
//
//  Created by Filip Dolnik on 31.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

public extension Property where T: PropertyOptionalType, T.Wrapped: PropertyValueType {
    
    func equalTo(_ value: T) -> Predicate<PARENT> {
        return Predicate.singleValuePredicate(name, value: value.value?.toAnyObject(), operatorString: "==")
    }
    
    func notEqualTo(_ value: T) -> Predicate<PARENT> {
        return Predicate.singleValuePredicate(name, value: value.value?.toAnyObject(), operatorString: "!=")
    }
}

public func == <P, T: PropertyOptionalType>(lhs: Property<P, T>, rhs: T) -> Predicate<P> where T.Wrapped: PropertyValueType {
    return lhs.equalTo(rhs)
}

public func != <P, T: PropertyOptionalType>(lhs: Property<P, T>, rhs: T) -> Predicate<P> where T.Wrapped: PropertyValueType {
    return lhs.notEqualTo(rhs)
}
