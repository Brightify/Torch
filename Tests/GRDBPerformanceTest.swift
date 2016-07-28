//
//  GRDBPerformanceTest.swift
//  Torch
//
//  Created by Filip Dolnik on 28.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import XCTest
import GRDB

class GRDBPerformanceTest: XCTestCase {
    
    func testGRDBInsertValuesByColumnIndex() {
        measureBlock {
            let dbQueue = DatabaseQueue()
            try! dbQueue.inDatabase { db in
                try db.execute("CREATE TABLE items (i0 INT, i1 INT, i2 INT, i3 INT, i4 INT, i5 INT, i6 INT, i7 INT, i8 INT, i9 INT)")
            }
            
            try! dbQueue.inTransaction { db in
                let statement = try! db.updateStatement("INSERT INTO items (i0, i1, i2, i3, i4, i5, i6, i7, i8, i9) VALUES (?,?,?,?,?,?,?,?,?,?)")
                for i in 0..<20000 {
                    try statement.execute(arguments: [i, i, i, i, i, i, i, i, i, i])
                }
                return .Commit
            }
        }
    }
    
    func testOtherData() {
        let dbQueue = DatabaseQueue()
        dbQueue.inDatabase {
            try! $0.execute("CREATE TABLE IF NOT EXISTS TorchTests_OtherData (id INTEGER PRIMARY KEY, text TEXT)")
        }
        measureBlock {
            dbQueue.inDatabase { db in
                (0...20000).forEach { i in
                    try! db.execute("INSERT INTO TorchTests_OtherData (id, text) VALUES (?,?)", arguments: [nil, String(i)])
                }
            }
        }
    }
}