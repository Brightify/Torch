//
//  PropertyOptionalTypeConvertible+Predicate.swift
//  Torch
//
//  Created by Filip Dolnik on 04.08.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

public extension Property where T: PropertyOptionalType, T.Wrapped: PropertyValueTypeConvertible {
    
    public func equalTo(_ value: T) -> Predicate<PARENT> {
        if let value = value.value {
            return Predicate.singleValuePredicate(name, value: value.toValue().toAnyObject(), operatorString: "==")
        } else {
            return Predicate.singleValuePredicate(Utils.getIsNilVariableName(name), value: nil, operatorString: "==")
        }
    }
    
    public func notEqualTo(_ value: T) -> Predicate<PARENT> {
        if let value = value.value {
            return Predicate.singleValuePredicate(name, value: value.toValue().toAnyObject(), operatorString: "!=")
        } else {
            return Predicate.singleValuePredicate(Utils.getIsNilVariableName(name), value: nil, operatorString: "!=")
        }
    }
}

public func == <P, T: PropertyOptionalType>(lhs: Property<P, T>, rhs: T) -> Predicate<P> where T.Wrapped: PropertyValueTypeConvertible {
    return lhs.equalTo(rhs)
}

public func != <P, T: PropertyOptionalType>(lhs: Property<P, T>, rhs: T) -> Predicate<P> where T.Wrapped: PropertyValueTypeConvertible {
    return lhs.notEqualTo(rhs)
}
