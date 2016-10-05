//
//  Predicate.swift
//  Torch
//
//  Created by Filip Dolnik on 31.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Foundation

// Generic structs do not support static constants.
private let ParentPropertyToken = "%K"

private extension String {
    
    func stringByReplacingParentPropertyToken(_ with: String) -> String {
        return replacingOccurrences(of: ParentPropertyToken, with: with)
    }
}

public struct Predicate<PARENT: TorchEntity> {
    
    fileprivate let predicateString: String
    fileprivate let predicateArguments: [AnyObject]
    
    static func boolPredicate(_ value: Bool) -> Predicate {
        return Predicate(predicateString: value ? "TRUEPREDICATE" : "FALSEPREDICATE", predicateArguments: [])
    }
    
    static func singleValuePredicate(_ property: String, value: AnyObject?, operatorString: String) -> Predicate {
        return Predicate(predicateString: "\(getPropertyName(property)) \(operatorString) %@", predicateArguments: [value ?? NSNull()])
    }
    
    static func compoundPredicate(_ first: Predicate, second: Predicate, operatorString: String) -> Predicate {
        let predicateString = "(\(first.predicateString) \(operatorString) \(second.predicateString))"
        return Predicate(predicateString: predicateString, predicateArguments: first.predicateArguments + second.predicateArguments)
    }
    
    static func negatePredicate(_ predicate: Predicate) -> Predicate {
        return Predicate(predicateString: "!(\(predicate.predicateString))", predicateArguments: predicate.predicateArguments)
    }
    
    static func parentPropertyPredicate<T: TorchEntity, P: PropertyType>(_ parentProperty: Property<T, P>, predicate: Predicate) -> Predicate<T> {
        let predicateString = predicate.predicateString.stringByReplacingParentPropertyToken(getPropertyName(parentProperty.name) + ".")
        return Predicate<T>(predicateString: predicateString, predicateArguments: predicate.predicateArguments)
    }
    
    fileprivate static func getPropertyName(_ property: String) -> String {
        return ParentPropertyToken + property
    }
    
    func toPredicate() -> NSPredicate {
        let predicateFormat = predicateString.stringByReplacingParentPropertyToken("")
        return NSPredicate(format: predicateFormat, argumentArray: predicateArguments)
    }
}

public extension Predicate {
    
    public func not() -> Predicate {
        return Predicate.negatePredicate(self)
    }
    
    public func or(_ other: Predicate) -> Predicate {
        return Predicate.compoundPredicate(self, second: other, operatorString: "||")
    }
    
    public func and(_ other: Predicate) -> Predicate {
        return Predicate.compoundPredicate(self, second: other, operatorString: "&&")
    }
}

public prefix func ! <P>(predicate: Predicate<P>) -> Predicate<P> {
    return predicate.not()
}

public func || <P>(lhs: Predicate<P>, rhs: Predicate<P>) -> Predicate<P> {
    return lhs.or(rhs)
}

public func && <P>(lhs: Predicate<P>, rhs: Predicate<P>) -> Predicate<P> {
    return lhs.and(rhs)
}
