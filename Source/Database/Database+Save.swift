//
//  Database+Save.swift
//  Torch
//
//  Created by Tadeáš Kříž on 24/07/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Foundation

extension Database {
    /**
     Saves object current state to database. Creates new object in database if necessery (id doesn`t exist yet or is nil).
     If object doesn`t have id it is not possible to use it afterwards (next invocation of save will create new object).
     If you do want to continue using the same object without loading it from database you can use `create` instead.
     */
    @discardableResult
    public func save<T: TorchEntity>(_ entities: T...) -> Database where T.IdType == Int {
        return save(entities)
    }

    @discardableResult
    public func save<T: TorchEntity>(_ entities: T...) -> Database where T.IdType == String {
        return save(entities)
    }

    @discardableResult
    public func save<T: TorchEntity>(_ entities: [T]) -> Database where T.IdType == Int {
        var mutableEntities = entities
        create(&mutableEntities)
        return self
    }

    @discardableResult
    public func save<T: TorchEntity>(_ entities: [T]) -> Database where T.IdType == String {
        var mutableEntities = entities
        create(&mutableEntities)
        return self
    }

    /**
     Same as `save` except it is possible to set entity new id. This allows to use the same object after it was created. If object has id this method acts as `save`.
     */
    @discardableResult
    public func create<T: TorchEntity>(_ entity: inout T) -> Database where T.IdType == Int {
        ensureTransaction {
            _ = getManagedObject(&entity, assignId: self.assignId)
        }
        return self
    }

    @discardableResult
    public func create<T: TorchEntity>(_ entity: inout T) -> Database where T.IdType == String {
        ensureTransaction {
            _ = getManagedObject(&entity, assignId: self.assignId)
        }
        return self
    }

    @discardableResult
    public func create<T: TorchEntity>(_ entities: inout [T]) -> Database where T.IdType == Int {
        ensureTransaction {
            for i in entities.indices {
                create(&entities[i])
            }
        }
        return self
    }

    @discardableResult
    public func create<T: TorchEntity>(_ entities: inout [T]) -> Database where T.IdType == String {
        ensureTransaction {
            for i in entities.indices {
                create(&entities[i])
            }
        }
        return self
    }
}
