//
//  TestUtils.swift
//  Torch
//
//  Created by Filip Dolnik on 02.08.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import RealmSwift
import Torch

struct TestUtils {
    
    static func initDatabase() -> Database {
        let configuration = Realm.Configuration(inMemoryIdentifier: "memory")
        let realm = try! Realm(configuration: configuration)
        if realm.isInWriteTransaction {
            realm.cancelWrite()
        }
        try! realm.write {
            realm.deleteAll()
        }
        return try! Database(configuration: configuration)
    }
}
