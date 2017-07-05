//
//  Database+Delete.swift
//  Torch
//
//  Created by Tadeáš Kříž on 24/07/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Foundation

extension Database {

    @discardableResult
    public func delete<T: TorchEntity>(_ entities: T...) -> Database {
        return delete(entities)
    }

    @discardableResult
    public func delete<T: TorchEntity>(_ entities: [T]) -> Database {
        ensureTransaction {
            entities.forEach {
                if let object = realm.object(ofType: T.ManagedObjectType.self, forPrimaryKey: $0.id) {
                    deleteValueTypeWrappers(T.self, managedObject: object)
                    realm.delete(object)
                }
            }
        }
        return self
    }

    @discardableResult
    public func delete<T: TorchEntity>(_ type: T.Type, where predicate: Predicate<T>) -> Database {
        ensureTransaction {
            let objects = realm.objects(T.ManagedObjectType.self).filter(predicate.toPredicate())
            objects.forEach { deleteValueTypeWrappers(T.self, managedObject: $0) }
            realm.delete(objects)
        }
        return self
    }

    @discardableResult
    public func deleteAll<T: TorchEntity>(_ type: T.Type) -> Database {
        ensureTransaction {
            let objects = realm.objects(T.ManagedObjectType.self)
            objects.forEach { deleteValueTypeWrappers(T.self, managedObject: $0) }
            realm.delete(objects)
        }
        return self
    }
}
