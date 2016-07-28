//
//  PredicateConvertible.swift
//  Torch
//
//  Created by Tadeáš Kříž on 24/07/16.
//  Copyright © 2016 Brightify. All rights reserved.
//
/*
import Foundation

public protocol PredicateConvertible {
    associatedtype ParentType

    func toPredicate() -> NSPredicate
}

extension PredicateConvertible {
    public func typeErased() -> AnyPredicate<ParentType> {
        return AnyPredicate(predicate: self)
    }
}

extension PredicateConvertible {

    public func not() -> CompoundPredicate<ParentType> {
        return CompoundPredicate(type: .NotPredicateType, predicates: typeErased())
    }

    public func or<OTHER: PredicateConvertible where OTHER.ParentType == ParentType>(other: OTHER) -> CompoundPredicate<ParentType> {
        return CompoundPredicate(type: .OrPredicateType, predicates: typeErased(), other.typeErased())
    }

    public func and<OTHER: PredicateConvertible where OTHER.ParentType == ParentType>(other: OTHER) -> CompoundPredicate<ParentType> {
        return CompoundPredicate(type: .AndPredicateType, predicates: typeErased(), other.typeErased())
    }
}

public prefix func ! <P: PredicateConvertible>(predicate: P) -> CompoundPredicate<P.ParentType> {
    return predicate.not()
}

public func || <P1: PredicateConvertible, P2: PredicateConvertible where P1.ParentType == P2.ParentType>(lhs: P1, rhs: P2) -> CompoundPredicate<P1.ParentType> {
    return lhs.or(rhs)
}

public func && <P1: PredicateConvertible, P2: PredicateConvertible where P1.ParentType == P2.ParentType>(lhs: P1, rhs: P2) -> CompoundPredicate<P1.ParentType> {
    return lhs.and(rhs)
}*/
