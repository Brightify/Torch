//
//  TorchPredicate.swift
//  Torch
//
//  Created by Filip Dolnik on 20.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Foundation

public struct AnyPredicate<PARENT>: PredicateConvertible {
    public typealias ParentType = PARENT

    private let toPredicateFunction: () -> NSPredicate

    init<P: PredicateConvertible where P.ParentType == PARENT>(predicate: P) {
        toPredicateFunction = predicate.toPredicate
    }

    init(toPredicateFunction: () -> NSPredicate) {
        self.toPredicateFunction = toPredicateFunction
    }

    public func toPredicate() -> NSPredicate {
        return toPredicateFunction()
    }
}
