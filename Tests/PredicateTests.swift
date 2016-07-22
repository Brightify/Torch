//
//  PredicateTests.swift
//  Torch
//
//  Created by Filip Dolnik on 22.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import XCTest
import CoreData
import Torch

class PredicateTests: XCTestCase {
    
    private var database: UnsafeDatabase!
    
    override func setUp() {
        super.setUp()
        
        let inMemoryStore = StoreConfiguration(storeType: NSInMemoryStoreType, configuration: nil, storeURL: nil, options: nil)
        database = UnsafeDatabase(store: inMemoryStore, entities: Data.self, OtherData.self)
        database.write {
            let otherData = OtherData(id: 0, text: "a")
            database.save(otherData)
            database.save(OtherData(id: 1, text: "b"))
            database.save(OtherData(id: 2, text: "b"))
            database.save(Data(id: nil, number: 7, optionalNumber: nil, numbers: [1, 1, 2], text: "a",
                float: 1.1, double: 1.2, bool: true, relation: otherData, optionalRelation: nil,
                arrayWithRelation: [], readOnly: "ra"))
            database.save(Data(id: nil, number: 8, optionalNumber: 1, numbers: [1, 1, 2], text: "b",
                float: 1.2, double: 1.3, bool: true, relation: otherData, optionalRelation: otherData,
                arrayWithRelation: [], readOnly: "b"))
            database.save(Data(id: nil, number: 8, optionalNumber: 1, numbers: [1, 1, 2], text: "b",
                float: 1.2, double: 1.3, bool: false, relation: otherData, optionalRelation: nil,
                arrayWithRelation: [], readOnly: "c"))
        }
    }
    
    // EqualTo
    func testStringEqualTo() {
        XCTAssertEqual(2, database.load(OtherData.self, where: OtherData.text.equalTo("b")).count)
        XCTAssertEqual(2, database.load(OtherData.self, where: OtherData.text == "b").count)
    }

    func testIntEqualTo() {
        XCTAssertEqual(2, database.load(Data.self, where: Data.number.equalTo(8)).count)
        XCTAssertEqual(2, database.load(Data.self, where: Data.number == 8).count)
    }
    
    func testFloatEqualTo() {
        XCTAssertEqual(2, database.load(Data.self, where: Data.float.equalTo(1.2)).count)
        XCTAssertEqual(2, database.load(Data.self, where: Data.float == 1.2).count)
    }
    
    func testDoubleEqualTo() {
        XCTAssertEqual(2, database.load(Data.self, where: Data.double.equalTo(1.3)).count)
        XCTAssertEqual(2, database.load(Data.self, where: Data.double == 1.3).count)
    }
    
    func testBoolEqualTo() {
        XCTAssertEqual(2, database.load(Data.self, where: Data.bool.equalTo(true)).count)
        XCTAssertEqual(2, database.load(Data.self, where: Data.bool == true).count)
    }
    
    // NotEqualTo
    func testStringNotEqualTo() {
        XCTAssertEqual(1, database.load(OtherData.self, where: OtherData.text.notEqualTo("b")).count)
        XCTAssertEqual(1, database.load(OtherData.self, where: OtherData.text != "b").count)
    }
    
    func testIntNotEqualTo() {
        XCTAssertEqual(1, database.load(Data.self, where: Data.number.notEqualTo(8)).count)
        XCTAssertEqual(1, database.load(Data.self, where: Data.number != 8).count)
    }
    
    // Compare
    func testIntLessThan() {
        XCTAssertEqual(1, database.load(Data.self, where: Data.number.lessThan(8)).count)
        XCTAssertEqual(1, database.load(Data.self, where: Data.number < 8).count)
    }
    
    func testIntLessThanOrEqualTo() {
        XCTAssertEqual(1, database.load(Data.self, where: Data.number.lessThanOrEqualTo(7)).count)
        XCTAssertEqual(1, database.load(Data.self, where: Data.number <= 7).count)
    }
    
    func testIntGreaterThanOrEqualTo() {
        XCTAssertEqual(2, database.load(Data.self, where: Data.number.greaterThanOrEqualTo(8)).count)
        XCTAssertEqual(2, database.load(Data.self, where: Data.number >= 8).count)
    }
    
    func testIntGreaterThan() {
        XCTAssertEqual(2, database.load(Data.self, where: Data.number.greaterThan(7)).count)
        XCTAssertEqual(2, database.load(Data.self, where: Data.number > 7).count)
    }
    
    // OptionalEqualTo
    
    func testOptionalIntEqualTo() {
        XCTAssertEqual(2, database.load(Data.self, where: Data.optionalNumber.equalTo(1)).count)
        XCTAssertEqual(2, database.load(Data.self, where: Data.optionalNumber == 1).count)
    }
    
    // OptionalNotEqualTo
    
    func testOptionalIntNotEqualTo() {
        XCTAssertEqual(2, database.load(Data.self, where: Data.optionalNumber.notEqualTo(nil)).count)
        XCTAssertEqual(2, database.load(Data.self, where: Data.optionalNumber != nil).count)
    }
    
    // OptionalCompare
    func testOptionalIntLessThan() {
        XCTAssertEqual(2, database.load(OtherData.self, where: OtherData.id.lessThan(2)).count)
        XCTAssertEqual(2, database.load(OtherData.self, where: OtherData.id < 2).count)
    }
    
    func testOptionalIntLessThanOrEqualTo() {
        XCTAssertEqual(2, database.load(OtherData.self, where: OtherData.id.lessThanOrEqualTo(1)).count)
        XCTAssertEqual(2, database.load(OtherData.self, where: OtherData.id <= 1).count)
    }
    
    func testOptionalIntGreaterThanOrEqualTo() {
        XCTAssertEqual(2, database.load(OtherData.self, where: OtherData.id.greaterThanOrEqualTo(1)).count)
        XCTAssertEqual(2, database.load(OtherData.self, where: OtherData.id >= 1).count)
    }
    
    func testOptionalIntGreaterThan() {
        XCTAssertEqual(2, database.load(OtherData.self, where: OtherData.id.greaterThan(0)).count)
        XCTAssertEqual(2, database.load(OtherData.self, where: OtherData.id > 0).count)
    }

    func testOptionalIntCompareNil() {
        XCTAssertEqual(0, database.load(Data.self, where: Data.optionalNumber < nil).count)
        XCTAssertEqual(1, database.load(Data.self, where: Data.optionalNumber <= nil).count)
        XCTAssertEqual(1, database.load(Data.self, where: Data.optionalNumber >= nil).count)
        XCTAssertEqual(0, database.load(Data.self, where: Data.optionalNumber > nil).count)
    }
}
