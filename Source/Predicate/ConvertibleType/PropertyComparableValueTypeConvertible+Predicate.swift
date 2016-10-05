//
//  PropertyComparableValueTypeConvertible+Predicate.swift
//  Torch
//
//  Created by Filip Dolnik on 04.08.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

public extension Property where T: PropertyValueTypeConvertible, T.ValueType: PropertyComparableValueType {
    
    public func lessThan(_ value: T) -> Predicate<PARENT> {
        return Predicate.singleValuePredicate(name, value: value.toValue().toAnyObject(), operatorString: "<")
    }
    
    public func lessThanOrEqualTo(_ value: T) -> Predicate<PARENT> {
        return Predicate.singleValuePredicate(name, value: value.toValue().toAnyObject(), operatorString: "<=")
    }
    
    public func greaterThanOrEqualTo(_ value: T) -> Predicate<PARENT> {
        return Predicate.singleValuePredicate(name, value: value.toValue().toAnyObject(), operatorString: ">=")
    }
    
    public func greaterThan(_ value: T) -> Predicate<PARENT> {
        return Predicate.singleValuePredicate(name, value: value.toValue().toAnyObject(), operatorString: ">")
    }
}

public func < <P, T: PropertyValueTypeConvertible>(lhs: Property<P, T>, rhs: T) -> Predicate<P> where T.ValueType: PropertyComparableValueType {
    return lhs.lessThan(rhs)
}

public func <= <P, T: PropertyValueTypeConvertible>(lhs: Property<P, T>, rhs: T) -> Predicate<P> where T.ValueType: PropertyComparableValueType {
    return lhs.lessThanOrEqualTo(rhs)
}

public func >= <P, T: PropertyValueTypeConvertible>(lhs: Property<P, T>, rhs: T) -> Predicate<P> where T.ValueType: PropertyComparableValueType {
    return lhs.greaterThanOrEqualTo(rhs)
}

public func > <P, T: PropertyValueTypeConvertible>(lhs: Property<P, T>, rhs: T) -> Predicate<P> where T.ValueType: PropertyComparableValueType {
    return lhs.greaterThan(rhs)
}
