//
//  TorchPredicate.swift
//  Torch
//
//  Created by Filip Dolnik on 20.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import CoreData

public struct TorchPredicate<PARENT: TorchEntity> {
    
    private let predicate: NSPredicate
    
    public init(predicate: NSPredicate) {
        self.predicate = predicate
    }
    
    public init(value: Bool) {
        predicate = NSPredicate(value: value)
    }
    
    public init(torchName: String, operatorString: String, value: NSObject) {
        self.init(torchName: torchName, operatorString: operatorString, value: value as NSObject?)
    }
    
    public init(torchName: String, operatorString: String, value: NSObject?) {
        predicate = NSPredicate(format: "%K \(operatorString) %@", torchName, value ?? NSNull())
    }
    
    public func toPredicate() -> NSPredicate {
        return predicate
    }
    
    public func or(other: TorchPredicate<PARENT>) -> TorchPredicate<PARENT> {
        return TorchPredicate(predicate: NSCompoundPredicate(orPredicateWithSubpredicates: [self.toPredicate(), other.toPredicate()]))
    }
    
    public func and(other: TorchPredicate<PARENT>) -> TorchPredicate<PARENT> {
        return TorchPredicate(predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [self.toPredicate(), other.toPredicate()]))
    }
}

public func || <PARENT: TorchEntity>(lhs: TorchPredicate<PARENT>, rhs: TorchPredicate<PARENT>) -> TorchPredicate<PARENT> {
    return lhs.or(rhs)
}

public func && <PARENT: TorchEntity>(lhs: TorchPredicate<PARENT>, rhs: TorchPredicate<PARENT>) -> TorchPredicate<PARENT> {
    return lhs.and(rhs)
}
