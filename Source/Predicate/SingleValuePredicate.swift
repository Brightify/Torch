//
//  SingleValuePredicate.swift
//  Torch
//
//  Created by Tadeáš Kříž on 24/07/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Foundation

public struct SingleValuePredicate<PARENT: TorchEntity>: PredicateConvertible {
    public typealias ParentType = PARENT

    public let keyPath: String
    public let operatorString: String
    public let value: NSObject

    public func toPredicate() -> NSPredicate {
        return NSPredicate(format: "%K \(operatorString) %@", keyPath, value)
    }
}
