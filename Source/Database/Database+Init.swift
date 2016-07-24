//
//  Database+Init.swift
//  Torch
//
//  Created by Tadeáš Kříž on 24/07/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

extension Database {
    public convenience init(store: StoreConfiguration, entities: TorchEntity.Type...) throws {
        try self.init(store: store, entities: entities)
    }

    public convenience init(store: StoreConfiguration, bundle: TorchEntityBundle) throws {
        try self.init(store: store, entities: bundle.entityTypes)
    }

    public func unsafeInstance() -> UnsafeDatabase {
        return UnsafeDatabase(database: self)
    }
}