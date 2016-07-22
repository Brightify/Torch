//
//  PropertyPredicates.swift
//  Torch
//
//  Created by Filip Dolnik on 20.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

public extension TypedTorchProperty where ValueType: NSObjectConvertible {
    public func equalTo(value: ValueType) -> TorchPredicate<ParentType> {
        return TorchPredicate(torchName: torchName, operatorString: "==", value: value.toNSObject())
    }
}

public extension TypedTorchProperty where ValueType: NSNumberConvertible {
    
    public func lessThan(value: ValueType) -> TorchPredicate<ParentType> {
        return TorchPredicate(torchName: torchName, operatorString: "<", value: value.toNSNumber())
    }
    
    public func lessThanOrEqualTo(value: ValueType) -> TorchPredicate<ParentType> {
        return TorchPredicate(torchName: torchName, operatorString: "<=", value: value.toNSNumber())
    }
    
    public func greaterThanOrEqualTo(value: ValueType) -> TorchPredicate<ParentType> {
        return TorchPredicate(torchName: torchName, operatorString: ">=", value: value.toNSNumber())
    }
    
    public func greaterThan(value: ValueType) -> TorchPredicate<ParentType> {
        return TorchPredicate(torchName: torchName, operatorString: ">", value: value.toNSNumber())
    }
}

public func == <P1: TypedTorchProperty where P1.ValueType: NSObjectConvertible>(lhs: P1, rhs: P1.ValueType) -> TorchPredicate<P1.ParentType> {
    return lhs.equalTo(rhs)
}

public func < <P1: TypedTorchProperty where P1.ValueType: NSNumberConvertible>(lhs: P1, rhs: P1.ValueType) -> TorchPredicate<P1.ParentType> {
    return lhs.lessThan(rhs)
}

public func <= <P1: TypedTorchProperty where P1.ValueType: NSNumberConvertible>(lhs: P1, rhs: P1.ValueType) -> TorchPredicate<P1.ParentType> {
    return lhs.lessThanOrEqualTo(rhs)
}

public func >= <P1: TypedTorchProperty where P1.ValueType: NSNumberConvertible>(lhs: P1, rhs: P1.ValueType) -> TorchPredicate<P1.ParentType> {
    return lhs.greaterThanOrEqualTo(rhs)
}

public func > <P1: TypedTorchProperty where P1.ValueType: NSNumberConvertible>(lhs: P1, rhs: P1.ValueType) -> TorchPredicate<P1.ParentType> {
    return lhs.greaterThan(rhs)
}

public extension TypedTorchProperty where ValueType: OptionalType, ValueType.WrappedType: NSObjectConvertible {
    public func equalTo(value: ValueType) -> TorchPredicate<ParentType> {
        return TorchPredicate(torchName: torchName, operatorString: "==", value: value.value?.toNSObject())
    }
}
