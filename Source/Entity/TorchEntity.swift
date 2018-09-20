//
//  TorchEntity.swift
//  Torch
//
//  Created by Filip Dolnik on 20.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Realm
import RealmSwift

public protocol TorchEntityId {
    static func initialValue() -> Self
}

extension String: TorchEntityId {
    public static func initialValue() -> String {
        return String()
    }
}

extension Int: TorchEntityId {
    public static func initialValue() -> Int {
        return Int()
    }
}

public protocol TorchEntity: PropertyType {
    associatedtype ManagedObjectType: Object, ManagedObject where ManagedObjectType.IdType == IdType
    associatedtype IdType: TorchEntityId

    var id: IdType? { get set }

    init(fromManagedObject object: ManagedObjectType)

    mutating func torch_update(managedObject object: ManagedObjectType, database: Database)
    
    static func torch_delete(managedObject object: ManagedObjectType, deleteFunction: (RealmSwift.Object) -> Void)
}

protocol TorchEnum: RealmCollectionValue { }

#if swift(>=3.4) && (swift(>=4.1.50) || !swift(>=4))
extension TorchEnum where Self: RawRepresentable, RawValue: RealmCollectionValue {
    static func _rlmArray() -> RLMArray<AnyObject> {
        return RawValue._rlmArray()
    }

    static func _nilValue() -> Self {
        return Self.init(rawValue: RawValue._nilValue())!
    }
}
#else
extension TorchEnum where RawValue: RealmCollectionValue {
    static func _rlmArray() -> RLMArray<AnyObject> {
        return RawValue._rlmArray()
    }
}
#endif


