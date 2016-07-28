//
//  AggregatePredicate.swift
//  Torch
//
//  Created by Tadeáš Kříž on 24/07/16.
//  Copyright © 2016 Brightify. All rights reserved.
//
/*
import Foundation

func joinKeyPaths(path1: String, _ path2: String) -> String {
    return "\(path1).\(path2)"
}

public enum AggregatePredicateType: String {
    case Any
    case All
    case None
}

public struct AggregatePredicate<PARENT: TorchEntity>: PredicateConvertible {
    public typealias ParentType = PARENT

    public let type: AggregatePredicateType
    public let keyPath: String
    public let operatorString: String
    public let value: NSObject

    public func toPredicate() -> NSPredicate {
        return NSPredicate(format: "\(type.rawValue.uppercaseString) %K \(operatorString) %@", keyPath, value)
    }
}*/