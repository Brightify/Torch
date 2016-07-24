//
//  CompoundPredicate.swift
//  Torch
//
//  Created by Tadeáš Kříž on 24/07/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Foundation

public struct CompoundPredicate<PARENT>: PredicateConvertible {
    public typealias ParentType = PARENT

    let type: NSCompoundPredicateType
    let predicates: [AnyPredicate<PARENT>]

    init(type: NSCompoundPredicateType, predicates: AnyPredicate<PARENT>...) {
        self.init(type: type, predicates: predicates)
    }

    init(type: NSCompoundPredicateType, predicates: [AnyPredicate<PARENT>]) {
        self.type = type
        self.predicates = predicates
    }

    public func toPredicate() -> NSPredicate {
        return NSCompoundPredicate(type: type, subpredicates: predicates.map { $0.toPredicate() })
    }
}
