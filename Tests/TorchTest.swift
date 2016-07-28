//
//  TorchTest.swift
//  Torch
//
//  Created by Filip Dolnik on 19.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import XCTest
import CoreData
import Torch
/*
class TorchTest: XCTestCase {
    
    private var database: UnsafeDatabase!
    
    override func setUp() {
        super.setUp()
        
        let inMemoryStore = StoreConfiguration(storeType: NSInMemoryStoreType, configuration: nil, storeURL: nil, options: nil)
        database = try! Database(store: inMemoryStore, bundle: TorchTestsEntityBundle()).unsafeInstance()
    }
    
    func testPersistance() {
        let manualData = ManualData.Root(id: 0, text: "manual")
        let otherData = OtherData(id: 0, text: "other")
        let data = Data(id: 0, number: 7, optionalNumber: 10, numbers: [1, 1, 2], text: "text",
                        float: 1.1, double: 1.2, bool: true, set: [1, 2], relation: otherData, optionalRelation: otherData,
                        arrayWithRelation: [otherData], manualEntityRelation: manualData, readOnly: "read only")
        let dataWithOptionals = Data(id: 1, number: 7, optionalNumber: nil, numbers: [1, 2], text: "text",
                        float: 1.1, double: 1.2, bool: true, set: [1, 2], relation: otherData, optionalRelation: nil,
                        arrayWithRelation: [otherData], manualEntityRelation: manualData, readOnly: "read only")
        
        database.save(data, dataWithOptionals).write()
        
        let loadedOtherData = database.load(OtherData.self)
        XCTAssertEqual(2, database.load(Data.self).count)
        XCTAssertEqual(1, loadedOtherData.count)
        XCTAssertEqual(String(data), String(database.load(Data.self, where: Data.id == 0).first!))
        XCTAssertEqual(String(dataWithOptionals), String(database.load(Data.self, where: Data.id == 1).first!))
        XCTAssertEqual(String(otherData), String(loadedOtherData.first!))
    }
    
    func testIdAssignment() {
        let data0 = OtherData(id: nil, text: "0")
        let data10 = OtherData(id: 10, text: "10")
        let data11 = OtherData(id: nil, text: "11")
        
        database.write {
            database.save(data0, data10, data11)
        }
        
        let loadedData = database.load(OtherData.self)
        XCTAssertEqual(3, loadedData.count)
        loadedData.map { (expected: Int($0.text), actual: $0.id) }.forEach {
            XCTAssertEqual($0.expected, $0.actual)
        }
    }
    
    func testCreate() {
        var mutableData = OtherData(id: nil, text: "var")
        let data = OtherData(id: nil, text: "let")
        
        database.write {
            database.create(&mutableData)
            database.create(&mutableData)
            database.save(mutableData)
            
            database.save(data)
            database.save(data)
        }
        
        XCTAssertEqual(1, database.load(OtherData.self, where: OtherData.text == "var").count)
        XCTAssertEqual(2, database.load(OtherData.self, where: OtherData.text == "let").count)
    }
    
    func testCreateArray() {
        let data = OtherData(id: nil, text: "let")
        var array = [OtherData(id: nil, text: "array"), data]
        
        database.write {
            database.create(&array)
            database.create(&array[0])
            database.create(&array[1])
            database.save(array)
            database.save(array[0])
            database.save(array[1])
            
            database.save(data)
        }
        
        XCTAssertEqual(1, database.load(OtherData.self, where: OtherData.text == "array").count)
        XCTAssertEqual(2, database.load(OtherData.self, where: OtherData.text == "let").count)
    }
    
    func testModification() {
        var data = OtherData(id: nil, text: "let")
        var mutableData = OtherData(id: nil, text: "var")
        
        database.write {
            database.create(&mutableData)
            database.save(data)
            
            mutableData.text = "mutated var"
            data.text = "mutated let"
            
            database.save(data, mutableData)
        }
        
        XCTAssertEqual(1, database.load(OtherData.self, where: OtherData.text == "mutated var").count)
        XCTAssertEqual(1, database.load(OtherData.self, where: OtherData.text == "let").count)
        XCTAssertEqual(1, database.load(OtherData.self, where: OtherData.text == "mutated let").count)
    }
    
    func testRollback() {
        let data = OtherData(id: nil, text: "")
        database.save(data)
        XCTAssertEqual(1, database.load(OtherData.self).count)
        
        database.rollback()
        
        XCTAssertEqual(0, database.load(OtherData.self).count)
    }
    
    func testWrite() {
        let data = OtherData(id: nil, text: "")
        database.save(data).write()
        XCTAssertEqual(1, database.load(OtherData.self).count)
        
        database.rollback()
        
        XCTAssertEqual(1, database.load(OtherData.self).count)
    }
    
    func testDelete() {
        var data = OtherData(id: nil, text: "")
        var secondData = OtherData(id: nil, text: "")
        database.create(&data).create(&secondData).write()
        
        database.delete(data, secondData)
        
        XCTAssertEqual(0, database.load(OtherData.self).count)
    }
    
    func testDeleteTypeWithPredicate() {
        let data = OtherData(id: 0, text: "")
        let secondData = OtherData(id: 1, text: "")
        database.save(data, secondData).write()
        
        database.delete(OtherData.self, where: OtherData.id == 1)
        
        XCTAssertEqual(1, database.load(OtherData.self).count)
    }
    
    func testDeleteAll() {
        let data = OtherData(id: 0, text: "")
        let secondData = OtherData(id: 1, text: "")
        database.save(data, secondData).write()
        
        database.deleteAll(OtherData.self)
        
        XCTAssertEqual(0, database.load(OtherData.self).count)
    }
}*/
