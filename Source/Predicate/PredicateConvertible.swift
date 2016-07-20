//
//  PredicateConvertible.swift
//  Torch
//
//  Created by Filip Dolnik on 20.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import CoreData

public protocol PredicateConvertible {
    associatedtype ParentType
    
    func toPredicate() -> NSPredicate
}

extension PredicateConvertible {
    public func typeErased() -> AnyPredicate<ParentType> {
        return AnyPredicate(toPredicateFunction: toPredicate)
    }
}

extension PredicateConvertible {
    
    public func or<OTHER: PredicateConvertible where OTHER.ParentType == ParentType>(other: OTHER) -> AnyPredicate<ParentType> {
        return AnyPredicate {
            NSCompoundPredicate(orPredicateWithSubpredicates: [self.toPredicate(), other.toPredicate()])
        }
    }
    
    public func and<OTHER: PredicateConvertible where OTHER.ParentType == ParentType>(other: OTHER) -> AnyPredicate<ParentType> {
        return AnyPredicate {
            NSCompoundPredicate(andPredicateWithSubpredicates: [self.toPredicate(), other.toPredicate()])
        }
    }
}

public func || <P1: PredicateConvertible, P2: PredicateConvertible where P1.ParentType == P2.ParentType>(lhs: P1, rhs: P2) -> AnyPredicate<P1.ParentType> {
    return lhs.or(rhs)
}

public func && <P1: PredicateConvertible, P2: PredicateConvertible where P1.ParentType == P2.ParentType>(lhs: P1, rhs: P2) -> AnyPredicate<P1.ParentType> {
    return lhs.and(rhs)
}

public struct AnyPredicate<PARENT>: PredicateConvertible {
    public typealias ParentType = PARENT
    
    private let toPredicateFunction: () -> NSPredicate
    
    public func toPredicate() -> NSPredicate {
        return toPredicateFunction()
    }
}

public struct SingleValuePredicate<PARENT, VALUE: NSObject>: PredicateConvertible {
    public typealias ParentType = PARENT
    
    public let propertyName: String
    public let operatorString: String
    public let value: VALUE
    
    public func toPredicate() -> NSPredicate {
        return NSPredicate(format: "%K \(operatorString) %@", propertyName, value)
    }
}

public struct OptionalSingleValuePredicate<PARENT, VALUE: NSObject>: PredicateConvertible {
    public typealias ParentType = PARENT
    
    public let propertyName: String
    public let operatorString: String
    public let value: VALUE?
    
    public func toPredicate() -> NSPredicate {
        return NSPredicate(format: "%K \(operatorString) %@", propertyName, value ?? NSNull())
    }
}

public struct BoolPredicate<PARENT>: PredicateConvertible {
    public typealias ParentType = PARENT
    
    public let value: Bool
    
    public func toPredicate() -> NSPredicate {
        return NSPredicate(value: value)
    }
}