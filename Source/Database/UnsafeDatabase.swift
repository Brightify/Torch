//
//  UnsafeDatabase.swift
//  Torch
//
//  Created by Filip Dolnik on 20.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

/// Wrapper for Database that is crashing with fatalError instead of throwing errors.
public class UnsafeDatabase {

    private let database: Database

    internal init(database: Database) {
        self.database = database
    }
}

// MARK: - Load
extension UnsafeDatabase {
    
    public func load<T: TorchEntity>(type: T.Type) -> [T] {
        return try! database.load(type)
    }
/*
    public func load<T: TorchEntity>(type: T.Type, sortBy sortDescriptors: SortDescriptor<T>...) -> [T] {
        return load(type, sortBy: sortDescriptors)
    }

    public func load<T: TorchEntity>(type: T.Type, sortBy sortDescriptors: [SortDescriptor<T>]) -> [T] {
        return try! database.load(type, sortBy: sortDescriptors)
    }

    public func load<T: TorchEntity, P: PredicateConvertible where P.ParentType == T>(type: T.Type, where predicate: P, sortBy sortDescriptors: SortDescriptor<T>...) -> [T] {
        return load(type, where: predicate, sortBy: sortDescriptors)
    }

    public func load<T: TorchEntity, P: PredicateConvertible where P.ParentType == T>(type: T.Type, where predicate: P, sortBy sortDescriptors: [SortDescriptor<T>]) -> [T] {
        return try! database.load(type, where: predicate, sortBy: sortDescriptors)
    }*/

}

// MARK: - Save
extension UnsafeDatabase {

    /// See `Database.save`
    public func save<T: TorchEntity>(entities: T...) -> UnsafeDatabase {
        return save(entities)
    }

    public func save<T: TorchEntity>(entities: [T]) -> UnsafeDatabase {
        try! database.save(entities)
        return self
    }

    /// See `Database.create`
    public func create<T: TorchEntity>(inout entity: T) -> UnsafeDatabase {
        try! database.create(&entity)
        return self
    }

    public func create<T: TorchEntity>(inout entities: [T]) -> UnsafeDatabase {
        try! database.create(&entities)
        return self
    }
}

// MARK: - Delete
extension UnsafeDatabase {

    public func delete<T: TorchEntity>(entities: T...) -> UnsafeDatabase {
        delete(entities)
        return self
    }

    public func delete<T: TorchEntity>(entities: [T]) -> UnsafeDatabase {
        try! database.delete(entities)
        return self
    }
/*
    public func delete<T: TorchEntity, P: PredicateConvertible where P.ParentType == T>(type: T.Type, where predicate: P) -> UnsafeDatabase {
        try! database.delete(type, where: predicate)
        return self
    }*/

    public func deleteAll<T: TorchEntity>(type: T.Type) -> UnsafeDatabase {
        try! database.deleteAll(type)
        return self
    }
}