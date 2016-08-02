//
//  Database+Delete.swift
//  Torch
//
//  Created by Tadeáš Kříž on 24/07/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Foundation

extension Database {
    
    public func delete<T: TorchEntity>(entities: T...) -> Database {
        return delete(entities)
    }

    public func delete<T: TorchEntity>(entities: [T]) -> Database {
        entities.forEach {
            if let object = realm.objectForPrimaryKey(T.ManagedObjectType.self, key: $0.id) {
                deleteValueTypeWrappers(T.self, managedObject: object)
                realm.delete(object)
            }
        }
        return self
    }

    public func delete<T: TorchEntity>(type: T.Type, where predicate: Predicate<T>) -> Database {
        let objects = realm.objects(T.ManagedObjectType.self).filter(predicate.toPredicate())
        objects.forEach { deleteValueTypeWrappers(T.self, managedObject: $0) }
        realm.delete(objects)
        return self
    }

    public func deleteAll<T: TorchEntity>(type: T.Type) -> Database {
        let objects = realm.objects(T.ManagedObjectType.self)
        objects.forEach { deleteValueTypeWrappers(T.self, managedObject: $0) }
        realm.delete(objects)
        return self
    }
}