//
//  Database.swift
//  Torch
//
//  Created by Filip Dolnik on 20.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import RealmSwift

open class Database {
    
    public typealias OnWriteErrorListener = (Error) -> Void
    
    internal var metadata: [String:Metadata] = [:]
    
    internal let realm: Realm
    internal let defaultOnWriteError: OnWriteErrorListener
    
    public init(configuration: Realm.Configuration = Realm.Configuration.defaultConfiguration,
                defaultOnWriteError: @escaping OnWriteErrorListener = { fatalError(String(describing: $0)) }) throws {
        realm = try Realm(configuration: configuration)
        self.defaultOnWriteError = defaultOnWriteError
    }
}

extension Database {
    
    // Intentionally left `internal` because it is used in Utils and Save.
    internal func getManagedObject<T: TorchEntity>(_ entity: inout T) -> T.ManagedObjectType {
        if let id = entity.id, let managedObject = realm.object(ofType: T.ManagedObjectType.self, forPrimaryKey: id) {
            entity.torch_update(managedObject: managedObject, database: self)
            return managedObject
        } else {
            let id = assignId(&entity)
            let managedObject = T.ManagedObjectType()
            managedObject.id = id
            entity.torch_update(managedObject: managedObject, database: self)
            realm.add(managedObject)
            return managedObject
        }
    }
    
    // Intentionally left `internal` because it is used in Delete.
    internal func deleteValueTypeWrappers<T: TorchEntity>(_ type: T.Type, managedObject: T.ManagedObjectType) {
        T.torch_delete(managedObject: managedObject) {
            realm.delete($0)
        }
    }
    
    fileprivate func assignId<T: TorchEntity>(_ entity: inout T) -> Int {
        let metadata = getMetadata(String(describing: T.self))
        if let id = entity.id {
            metadata.lastAssignedId = max(metadata.lastAssignedId, id)
            return id
        } else {
            let id = metadata.lastAssignedId + 1
            metadata.lastAssignedId = id
            entity.id = id
            return id
        }
    }
    
    fileprivate func getMetadata(_ entityName: String) -> Metadata {
        if let result = metadata[entityName] {
            return result
        } else if let result = realm.object(ofType: Metadata.self, forPrimaryKey: entityName) {
            metadata[entityName] = result
            return result
        } else {
            let result = Metadata()
            result.entityName = entityName
            realm.add(result)
            return result
        }
    }

    internal func ensureTransaction(_ closure: () -> Void) {
        if realm.isInWriteTransaction {
            closure()
        } else {
            write { _ in closure() }
        }
    }
}
