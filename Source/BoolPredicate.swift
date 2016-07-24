//
//  BoolPredicate.swift
//  Torch
//
//  Created by Tadeáš Kříž on 24/07/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Foundation

public struct BoolPredicate<PARENT>: PredicateConvertible {
    public typealias ParentType = PARENT

    public let value: Bool

    public func toPredicate() -> NSPredicate {
        return NSPredicate(value: value)
    }
}
