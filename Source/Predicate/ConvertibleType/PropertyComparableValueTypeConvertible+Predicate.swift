//
//  PropertyComparableValueTypeConvertible+Predicate.swift
//  Torch
//
//  Created by Filip Dolnik on 04.08.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

public extension Property where T: PropertyValueTypeConvertible, T.ValueType: PropertyComparableValueType {
    
    public func lessThan(value: T) -> Predicate<PARENT> {
        return Predicate.singleValuePredicate(name, value: value.toValue().toAnyObject(), operatorString: "<")
    }
    
    public func lessThanOrEqualTo(value: T) -> Predicate<PARENT> {
        return Predicate.singleValuePredicate(name, value: value.toValue().toAnyObject(), operatorString: "<=")
    }
    
    public func greaterThanOrEqualTo(value: T) -> Predicate<PARENT> {
        return Predicate.singleValuePredicate(name, value: value.toValue().toAnyObject(), operatorString: ">=")
    }
    
    public func greaterThan(value: T) -> Predicate<PARENT> {
        return Predicate.singleValuePredicate(name, value: value.toValue().toAnyObject(), operatorString: ">")
    }
}

public func < <P, T: PropertyValueTypeConvertible where T.ValueType: PropertyComparableValueType>(lhs: Property<P, T>, rhs: T) -> Predicate<P> {
    return lhs.lessThan(rhs)
}

public func <= <P, T: PropertyValueTypeConvertible where T.ValueType: PropertyComparableValueType>(lhs: Property<P, T>, rhs: T) -> Predicate<P> {
    return lhs.lessThanOrEqualTo(rhs)
}

public func >= <P, T: PropertyValueTypeConvertible where T.ValueType: PropertyComparableValueType>(lhs: Property<P, T>, rhs: T) -> Predicate<P> {
    return lhs.greaterThanOrEqualTo(rhs)
}

public func > <P, T: PropertyValueTypeConvertible where T.ValueType: PropertyComparableValueType>(lhs: Property<P, T>, rhs: T) -> Predicate<P> {
    return lhs.greaterThan(rhs)
}