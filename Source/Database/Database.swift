//
//  Database.swift
//  Torch
//
//  Created by Filip Dolnik on 20.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import GRDB

public class Database {

    internal let dbQueue: DatabaseQueue
    
    public convenience init(storage: Storage, configuration: Configuration = Configuration(), bundle: TorchEntityBundle) throws {
        try self.init(storage: storage, configuration: configuration, entities: bundle.entityTypes)
    }
    
    public convenience init(storage: Storage, configuration: Configuration = Configuration(), entities: TorchEntity.Type...) throws {
        try self.init(storage: storage, configuration: configuration, entities: entities)
    }
    
    public init(storage: Storage, configuration: Configuration = Configuration(), entities: [TorchEntity.Type]) throws {
        switch storage {
        case .File(let path):
            dbQueue = try DatabaseQueue(path: path, configuration: configuration)
        case .Memory:
            dbQueue = DatabaseQueue(configuration: configuration)
        }
        
        try registerEntities(entities)
    }
    
    public func unsafeInstance() -> UnsafeDatabase {
        return UnsafeDatabase(database: self)
    }
}

extension Database {

    private func registerEntities(entities: [TorchEntity.Type]) throws {
        for entity in entities {
            let propertyRegistry = PropertyRegistry()
            entity.torch_describeProperties(to: propertyRegistry)
            let columns = propertyRegistry.registeredProperties.joinWithSeparator(",")
            try dbQueue.inDatabase {
                try $0.execute("CREATE TABLE IF NOT EXISTS \(entity.torch_name) (\(columns))")
            }
        }
    }
}
