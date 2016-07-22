//
//  OptionalPropertyPredicates.swift
//  Torch
//
//  Created by Filip Dolnik on 22.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

public extension TorchProperty where T: TorchPropertyOptionalType, T.Wrapped: NSObjectConvertible {
    public func equalTo(value: T) -> TorchPredicate<PARENT> {
        return TorchPredicate(torchName: torchName, operatorString: "==", value: value.value?.toNSObject())
    }
}

public extension TorchProperty where T: TorchPropertyOptionalType, T.Wrapped: NSNumberConvertible {
    
    public func lessThan(value: T) -> TorchPredicate<PARENT> {
        return TorchPredicate(torchName: torchName, operatorString: "<", value: value.value?.toNSNumber())
    }
    
    public func lessThanOrEqualTo(value: T) -> TorchPredicate<PARENT> {
        return TorchPredicate(torchName: torchName, operatorString: "<=", value: value.value?.toNSNumber())
    }
    
    public func greaterThanOrEqualTo(value: T) -> TorchPredicate<PARENT> {
        return TorchPredicate(torchName: torchName, operatorString: ">=", value: value.value?.toNSNumber())
    }
    
    public func greaterThan(value: T) -> TorchPredicate<PARENT> {
        return TorchPredicate(torchName: torchName, operatorString: ">", value: value.value?.toNSNumber())
    }
}

public func == <PARENT: TorchEntity, T: TorchPropertyOptionalType where T.Wrapped: NSNumberConvertible>(lhs: TorchProperty<PARENT, T>, rhs: T) -> TorchPredicate<PARENT> {
    return lhs.equalTo(rhs)
}

public func < <PARENT: TorchEntity, T: TorchPropertyOptionalType where T.Wrapped: NSNumberConvertible>(lhs: TorchProperty<PARENT, T>, rhs: T) -> TorchPredicate<PARENT> {
    return lhs.lessThan(rhs)
}

public func <= <PARENT: TorchEntity, T: TorchPropertyOptionalType where T.Wrapped: NSNumberConvertible>(lhs: TorchProperty<PARENT, T>, rhs: T) -> TorchPredicate<PARENT> {
    return lhs.lessThanOrEqualTo(rhs)
}

public func >= <PARENT: TorchEntity, T: TorchPropertyOptionalType where T.Wrapped: NSNumberConvertible>(lhs: TorchProperty<PARENT, T>, rhs: T) -> TorchPredicate<PARENT> {
    return lhs.greaterThanOrEqualTo(rhs)
}

public func > <PARENT: TorchEntity, T: TorchPropertyOptionalType where T.Wrapped: NSNumberConvertible>(lhs: TorchProperty<PARENT, T>, rhs: T) -> TorchPredicate<PARENT> {
    return lhs.greaterThan(rhs)
}