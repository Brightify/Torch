//
//  PropertyPredicates.swift
//  Torch
//
//  Created by Filip Dolnik on 20.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

public extension TorchProperty where T: NSObjectConvertible {
    
    public func equalTo(value: T) -> TorchPredicate<PARENT> {
        return TorchPredicate(torchName: torchName, operatorString: "==", value: value.toNSObject())
    }
    
    public func notEqualTo(value: T) -> TorchPredicate<PARENT> {
        return TorchPredicate(torchName: torchName, operatorString: "!=", value: value.toNSObject())
    }
}

public extension TorchProperty where T: NSNumberConvertible {
    
    public func lessThan(value: T) -> TorchPredicate<PARENT> {
        return TorchPredicate(torchName: torchName, operatorString: "<", value: value.toNSNumber())
    }
    
    public func lessThanOrEqualTo(value: T) -> TorchPredicate<PARENT> {
        return TorchPredicate(torchName: torchName, operatorString: "<=", value: value.toNSNumber())
    }
    
    public func greaterThanOrEqualTo(value: T) -> TorchPredicate<PARENT> {
        return TorchPredicate(torchName: torchName, operatorString: ">=", value: value.toNSNumber())
    }
    
    public func greaterThan(value: T) -> TorchPredicate<PARENT> {
        return TorchPredicate(torchName: torchName, operatorString: ">", value: value.toNSNumber())
    }
}

public func == <PARENT: TorchEntity, T: NSObjectConvertible>(lhs: TorchProperty<PARENT, T>, rhs: T) -> TorchPredicate<PARENT> {
    return lhs.equalTo(rhs)
}

public func != <PARENT: TorchEntity, T: NSObjectConvertible>(lhs: TorchProperty<PARENT, T>, rhs: T) -> TorchPredicate<PARENT> {
    return lhs.notEqualTo(rhs)
}

public func < <PARENT: TorchEntity, T: NSNumberConvertible>(lhs: TorchProperty<PARENT, T>, rhs: T) -> TorchPredicate<PARENT> {
    return lhs.lessThan(rhs)
}

public func <= <PARENT: TorchEntity, T: NSNumberConvertible>(lhs: TorchProperty<PARENT, T>, rhs: T) -> TorchPredicate<PARENT> {
    return lhs.lessThanOrEqualTo(rhs)
}

public func >= <PARENT: TorchEntity, T: NSNumberConvertible>(lhs: TorchProperty<PARENT, T>, rhs: T) -> TorchPredicate<PARENT> {
    return lhs.greaterThanOrEqualTo(rhs)
}

public func > <PARENT: TorchEntity, T: NSNumberConvertible>(lhs: TorchProperty<PARENT, T>, rhs: T) -> TorchPredicate<PARENT> {
    return lhs.greaterThan(rhs)
}
