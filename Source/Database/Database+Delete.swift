//
//  Database+Delete.swift
//  Torch
//
//  Created by Tadeáš Kříž on 24/07/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

// TODO Solve relations

extension Database {
    public func delete<T: TorchEntity>(entities: T...) throws -> Database {
        return try delete(entities)
    }

    public func delete<T: TorchEntity>(entities: [T]) throws -> Database {
        if entities.isEmpty == false {
            let ids = entities.map { String($0.id) }.joinWithSeparator(",")
            try dbQueue.inDatabase {
                try $0.execute("DELETE FROM \(T.torch_name) where id in (\(ids))")
            }
        }
        return self
    }
    // TODO Implement
/*
    public func delete<T: TorchEntity, P: PredicateConvertible where P.ParentType == T>(type: T.Type, where predicate: P) throws -> Database {
        try deleteImpl(type, predicate: predicate.toPredicate())
        return self
    }
*/
    public func deleteAll<T: TorchEntity>(type: T.Type) throws -> Database {
        try dbQueue.inDatabase {
            try $0.execute("DELETE FROM \(T.torch_name)")
        }
        return self
    }
}