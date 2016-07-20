//
//  PropertyPredicates.swift
//  Torch
//
//  Created by Filip Dolnik on 20.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

public extension TypedTorchProperty where ValueType: NSObjectConvertible {
    public func equalTo(value: ValueType) -> AnyPredicate<ParentType> {
        return SingleValuePredicate(propertyName: name, operatorString: "==", value: value.toNSObject()).typeErased()
    }
}

public extension TypedTorchProperty where ValueType: NSNumberConvertible {
    
    public func lessThan(value: ValueType) -> AnyPredicate<ParentType> {
        return SingleValuePredicate(propertyName: name, operatorString: "<", value: value.toNSNumber()).typeErased()
    }
    
    public func lessThanOrEqualTo(value: ValueType) -> AnyPredicate<ParentType> {
        return SingleValuePredicate(propertyName: name, operatorString: "<=", value: value.toNSNumber()).typeErased()
    }
    
    public func greaterThanOrEqualTo(value: ValueType) -> AnyPredicate<ParentType> {
        return SingleValuePredicate(propertyName: name, operatorString: ">=", value: value.toNSNumber()).typeErased()
    }
    
    public func greaterThan(value: ValueType) -> AnyPredicate<ParentType> {
        return SingleValuePredicate(propertyName: name, operatorString: ">", value: value.toNSNumber()).typeErased()
    }
}

public func == <P1: TypedTorchProperty where P1.ValueType: NSObjectConvertible>(lhs: P1, rhs: P1.ValueType) -> AnyPredicate<P1.ParentType> {
    return lhs.equalTo(rhs)
}

public func < <P1: TypedTorchProperty where P1.ValueType: NSNumberConvertible>(lhs: P1, rhs: P1.ValueType) -> AnyPredicate<P1.ParentType> {
    return lhs.lessThan(rhs)
}

public func <= <P1: TypedTorchProperty where P1.ValueType: NSNumberConvertible>(lhs: P1, rhs: P1.ValueType) -> AnyPredicate<P1.ParentType> {
    return lhs.lessThanOrEqualTo(rhs)
}

public func >= <P1: TypedTorchProperty where P1.ValueType: NSNumberConvertible>(lhs: P1, rhs: P1.ValueType) -> AnyPredicate<P1.ParentType> {
    return lhs.greaterThanOrEqualTo(rhs)
}

public func > <P1: TypedTorchProperty where P1.ValueType: NSNumberConvertible>(lhs: P1, rhs: P1.ValueType) -> AnyPredicate<P1.ParentType> {
    return lhs.greaterThan(rhs)
}

public extension TypedTorchProperty where ValueType: OptionalType, ValueType.WrappedType: NSObjectConvertible {
    public func equalTo(value: ValueType) -> AnyPredicate<ParentType> {
        return OptionalSingleValuePredicate(propertyName: name, operatorString: "==", value: value.value?.toNSObject()).typeErased()
    }
}
