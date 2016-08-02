//
//  Database.swift
//  Torch
//
//  Created by Filip Dolnik on 20.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import RealmSwift

public class Database {
    
    public typealias OnWriteErrorListener = (ErrorType) -> Void
    
    internal var metadata: [String:Metadata] = [:]
    
    internal let realm: Realm
    internal let defaultOnWriteError: OnWriteErrorListener
    
    public init(configuration: Realm.Configuration = Realm.Configuration.defaultConfiguration,
                defaultOnWriteError: OnWriteErrorListener = { fatalError(String($0)) }) throws {
        realm = try Realm(configuration: configuration)
        self.defaultOnWriteError = defaultOnWriteError
        
        if !realm.inWriteTransaction {
            realm.beginWrite()
        }
    }
    
    deinit {
        realm.cancelWrite()
    }
}

extension Database {
    
    // Intentionally left `internal` because it is used in Utils and Save.
    internal func getManagedObject<T: TorchEntity>(inout entity: T) -> T.ManagedObjectType {
        if let id = entity.id, managedObject = realm.objectForPrimaryKey(T.ManagedObjectType.self, key: id) {
            entity.torch_updateManagedObject(managedObject, database: self)
            return managedObject
        } else {
            assignId(&entity)
            let managedObject = T.ManagedObjectType()
            managedObject.id = entity.id!
            entity.torch_updateManagedObject(managedObject, database: self)
            realm.add(managedObject)
            return managedObject
        }
    }
    
    // Intentionally left `internal` because it is used in Delete.
    internal func deleteValueTypeWrappers<T: TorchEntity>(type: T.Type, managedObject: T.ManagedObjectType) {
        T.torch_deleteValueTypeWrappers(managedObject) {
            realm.delete($0)
        }
    }
    
    private func assignId<T: TorchEntity>(inout entity: T) {
        let metadata = getMetadata(String(T))
        if let id = entity.id {
            metadata.lastAssignedId = max(metadata.lastAssignedId, id)
        } else {
            metadata.lastAssignedId += 1
            entity.id = metadata.lastAssignedId
        }
    }
    
    private func getMetadata(entityName: String) -> Metadata {
        if let result = metadata[entityName] {
            return result
        } else if let result = realm.objectForPrimaryKey(Metadata.self, key: entityName) {
            metadata[entityName] = result
            return result
        } else {
            let result = Metadata()
            result.entityName = entityName
            realm.add(result)
            return result
        }
    }
}
