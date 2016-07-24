//
//  PropertyOperators.swift
//  Torch
//
//  Created by Tadeáš Kříž on 24/07/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Foundation

// MARK: - NSObjectConvertible
public extension TorchProperty where T: NSObjectConvertible {
    public func equalTo(value: T) -> SingleValuePredicate<PARENT> {
        return SingleValuePredicate(keyPath: torchName, operatorString: "==", value: value.toNSObject())
    }

    public func notEqualTo(value: T) -> SingleValuePredicate<PARENT> {
        return SingleValuePredicate(keyPath: torchName, operatorString: "!=", value: value.toNSObject())
    }
}

public func == <P, T: NSObjectConvertible>(lhs: TorchProperty<P, T>, rhs: T) -> SingleValuePredicate<P> {
    return lhs.equalTo(rhs)
}

public func != <P, T: NSObjectConvertible>(lhs: TorchProperty<P, T>, rhs: T) -> SingleValuePredicate<P> {
    return lhs.notEqualTo(rhs)
}

// MARK: NSNumberConvertible
public extension TorchProperty where T: NSNumberConvertible {

    public func lessThan(value: T) -> SingleValuePredicate<PARENT> {
        return SingleValuePredicate(keyPath: torchName, operatorString: "<", value: value.toNSNumber())
    }

    public func lessThanOrEqualTo(value: T) -> SingleValuePredicate<PARENT> {
        return SingleValuePredicate(keyPath: torchName, operatorString: "<=", value: value.toNSNumber())
    }

    public func greaterThanOrEqualTo(value: T) -> SingleValuePredicate<PARENT> {
        return SingleValuePredicate(keyPath: torchName, operatorString: ">=", value: value.toNSNumber())
    }

    public func greaterThan(value: T) -> SingleValuePredicate<PARENT> {
        return SingleValuePredicate(keyPath: torchName, operatorString: ">", value: value.toNSNumber())
    }
}

public func < <P, T: NSNumberConvertible>(lhs: TorchProperty<P, T>, rhs: T) -> SingleValuePredicate<P> {
    return lhs.lessThan(rhs)
}

public func <= <P, T: NSNumberConvertible>(lhs: TorchProperty<P, T>, rhs: T) -> SingleValuePredicate<P> {
    return lhs.lessThanOrEqualTo(rhs)
}

public func >= <P, T: NSNumberConvertible>(lhs: TorchProperty<P, T>, rhs: T) -> SingleValuePredicate<P> {
    return lhs.greaterThanOrEqualTo(rhs)
}

public func > <P, T: NSNumberConvertible>(lhs: TorchProperty<P, T>, rhs: T) -> SingleValuePredicate<P> {
    return lhs.greaterThan(rhs)
}

// MARK: - TorchEntity
public extension TorchProperty where T: TorchEntity {
    subscript(predicate: SingleValuePredicate<T>) -> SingleValuePredicate<PARENT> {
        return matches(predicate)
    }

    public func matches(predicate: SingleValuePredicate<T>) -> SingleValuePredicate<PARENT> {
        return SingleValuePredicate(keyPath: joinKeyPaths(torchName, predicate.keyPath),
                                    operatorString: predicate.operatorString,
                                    value: predicate.value)
    }
}
