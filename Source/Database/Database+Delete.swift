//
//  Database+Delete.swift
//  Torch
//
//  Created by Tadeáš Kříž on 24/07/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Foundation

extension Database {
    public func delete<T: TorchEntity>(entities: T...) throws -> Database {
        return try delete(entities)
    }

    public func delete<T: TorchEntity>(entities: [T]) throws -> Database {
        try deleteImpl(entities)
        return self
    }

    public func delete<T: TorchEntity, P: PredicateConvertible where P.ParentType == T>(type: T.Type, where predicate: P) throws -> Database {
        try deleteImpl(type, predicate: predicate.toPredicate())
        return self
    }

    public func deleteAll<T: TorchEntity>(type: T.Type) throws -> Database {
        try deleteImpl(type, predicate: nil)
        return self
    }
}