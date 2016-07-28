//
//  Database+Save.swift
//  Torch
//
//  Created by Tadeáš Kříž on 24/07/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import GRDB

extension Database {
    /**
     Saves object current state to database. Creates new object in database if necessery (id doesn`t exist yet or is nil).
     If object doesn`t have id it is not possible to use it afterwards (next invocation of save will create new object).
     If you do want to continue using the same object without loading it from database you can use `create` instead.
     */
    public func save<T: TorchEntity>(entities: T...) throws -> Database {
        return try save(entities)
    }

    public func save<T: TorchEntity>(entities: [T]) throws -> Database {
        try entities.forEach {
            var mutableEntity = $0
            try insertOrReplace(&mutableEntity)
        }
        return self
    }

    /**
     Same as `save` except it is possible to set entity new id. This allows to use the same object after it was created. If object has id this method acts as `save`.
     */
    public func create<T: TorchEntity>(inout entity: T) throws -> Database {
        try insertOrReplace(&entity)
        entity.id = entity.id ?? dbQueue.inDatabase { Int($0.lastInsertedRowID) }
        return self
    }

    public func create<T: TorchEntity>(inout entities: [T]) throws -> Database {
        for i in entities.indices {
            try create(&entities[i])
        }
        return self
    }
    
    private func insertOrReplace<T: TorchEntity>(inout entity: T) throws {
        let managedObject = ManagedObject(data: [:], database: self)
        try entity.torch_updateManagedObject(managedObject)
        let fields = managedObject.data.keys.joinWithSeparator(",")
        let valuesPlaceholder = (0..<managedObject.data.count).map { _ in "?" }.joinWithSeparator(",")
        let command: String
        if entity.id != nil {
            command = "REPLACE"
        } else {
            command = "INSERT"
        }
        try dbQueue.inDatabase {
            try $0.execute("\(command) INTO \(T.torch_name) (\(fields)) VALUES (\(valuesPlaceholder))",
                arguments: StatementArguments(managedObject.data.map { $0.1 }))
        }
    }
}