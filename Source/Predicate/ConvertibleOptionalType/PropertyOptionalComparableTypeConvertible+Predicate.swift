//
//  PropertyOptionalComparableTypeConvertible+Predicate.swift
//  Torch
//
//  Created by Filip Dolnik on 04.08.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

public extension Property where T: PropertyOptionalType, T.Wrapped: PropertyValueTypeConvertible, T.Wrapped.ValueType: PropertyComparableValueType {
    
    public func lessThan(_ value: T) -> Predicate<PARENT> {
        if let value = value.value {
            return Predicate.singleValuePredicate(name, value: value.toValue().toAnyObject(), operatorString: "<")
        } else {
            return Predicate.boolPredicate(false)
        }
    }
    
    public func lessThanOrEqualTo(_ value: T) -> Predicate<PARENT> {
        if let value = value.value {
            return Predicate.singleValuePredicate(name, value: value.toValue().toAnyObject(), operatorString: "<=")
        } else {
            return Predicate.singleValuePredicate(Utils.getIsNilVariableName(name), value: nil, operatorString: "==")
        }
    }
    
    public func greaterThanOrEqualTo(_ value: T) -> Predicate<PARENT> {
        if let value = value.value {
            return Predicate.singleValuePredicate(name, value: value.toValue().toAnyObject(), operatorString: ">=")
        } else {
            return Predicate.singleValuePredicate(Utils.getIsNilVariableName(name), value: nil, operatorString: "==")
        }
    }
    
    public func greaterThan(_ value: T) -> Predicate<PARENT> {
        if let value = value.value {
            return Predicate.singleValuePredicate(name, value: value.toValue().toAnyObject(), operatorString: ">")
        } else {
            return Predicate.boolPredicate(false)
        }
    }
}

public func < <P, T: PropertyOptionalType>(lhs: Property<P, T>, rhs: T) -> Predicate<P> where T.Wrapped: PropertyValueTypeConvertible, T.Wrapped.ValueType: PropertyComparableValueType {
    return lhs.lessThan(rhs)
}

public func <= <P, T: PropertyOptionalType>(lhs: Property<P, T>, rhs: T) -> Predicate<P> where T.Wrapped: PropertyValueTypeConvertible, T.Wrapped.ValueType: PropertyComparableValueType {
    return lhs.lessThanOrEqualTo(rhs)
}

public func >= <P, T: PropertyOptionalType>(lhs: Property<P, T>, rhs: T) -> Predicate<P> where T.Wrapped: PropertyValueTypeConvertible, T.Wrapped.ValueType: PropertyComparableValueType {
    return lhs.greaterThanOrEqualTo(rhs)
}

public func > <P, T: PropertyOptionalType>(lhs: Property<P, T>, rhs: T) -> Predicate<P> where T.Wrapped: PropertyValueTypeConvertible, T.Wrapped.ValueType: PropertyComparableValueType {
    return lhs.greaterThan(rhs)
}
