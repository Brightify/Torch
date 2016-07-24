//
//  Database+Load.swift
//  Torch
//
//  Created by Tadeáš Kříž on 24/07/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

public extension Database {
    public func load<T: TorchEntity>(type: T.Type, sortBy sortDescriptors: SortDescriptor<T>...) throws -> [T] {
        return try load(type, sortBy: sortDescriptors)
    }

    public func load<T: TorchEntity>(type: T.Type, sortBy sortDescriptors: [SortDescriptor<T>]) throws -> [T] {
        return try loadImpl(type, predicate: nil, sortDescriptors: sortDescriptors.map { $0.toSortDescriptor() } )
    }

    public func load<T: TorchEntity, P: PredicateConvertible where P.ParentType == T>(type: T.Type, where predicate: P, sortBy sortDescriptors: SortDescriptor<T>...) throws -> [T] {
        return try load(type, where: predicate, sortBy: sortDescriptors)
    }

    public func load<T: TorchEntity, P: PredicateConvertible where P.ParentType == T>(type: T.Type, where predicate: P, sortBy sortDescriptors: [SortDescriptor<T>]) throws -> [T] {
        return try loadImpl(type, predicate: predicate.toPredicate(),
                            sortDescriptors: sortDescriptors.map { $0.toSortDescriptor() })
    }
}
