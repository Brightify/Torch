//
//  PerformanceTest.swift
//  Torch
//
//  Created by Filip Dolnik on 25.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import XCTest
import RealmSwift
import Torch

class PerformanceTest: XCTestCase {

    static let OtherDataCount = 5000
    static let OtherDataWithIdCount = 1000
    static let DataCount = 500
    static let RelationsCount = 10
    
    private var database: Database!
    
    override func setUp() {
        super.setUp()
        
        database = TestUtils.initDatabase()
    }
    
    func testInit() {
        measureBlock {
            let _ = try! Database(configuration: Realm.Configuration(inMemoryIdentifier: String(PerformanceTest) + "testInit"))
        }
    }
    
    func testSave() {
        measureMetrics(performanceMetrics, automaticallyStartMeasuring: false) {
            self.measure {
                self.saveData()
            }
            
            self.database.deleteAll(OtherData)
            self.database.write()
        }
    }
    
    func testSaveWithId() {
        measureMetrics(performanceMetrics, automaticallyStartMeasuring: false) {
            self.measure {
                self.saveDataWithId()
            }
            
            self.database.deleteAll(OtherData)
            self.database.write()
        }
    }
    
    func testSaveComplex() {
        measureMetrics(performanceMetrics, automaticallyStartMeasuring: false) {
            self.measure {
                self.saveComplex()
            }
            
            self.database.deleteAll(OtherData)
            self.database.deleteAll(Data)
            
            self.database.write()
        }
    }
    
    func testUpdate() {
        self.saveComplex()
        database.write()
        let objects = database.load(Data)
        measureMetrics(performanceMetrics, automaticallyStartMeasuring: false) {
            self.measure {
                for var object in objects {
                    object.number = 0
                    object.optionalNumber = nil
                    object.numbers = [1, 2, 3]
                    self.database.save(object)
                }
            }
            
            self.database.rollback()
        }
    }
    
    func testLoad() {
        saveData()
        
        measureBlock {
            self.database.load(OtherData)
        }
    }
    
    func testRollback() {
        measureMetrics(performanceMetrics, automaticallyStartMeasuring: false) {
            self.saveData()
            
            self.measure {
                self.database.rollback()
            }
        }
    }
    
    func testWrite() {
        measureMetrics(performanceMetrics, automaticallyStartMeasuring: false) {
            self.saveData()
            
            self.measure {
                self.database.write()
            }
            
            self.database.deleteAll(OtherData)
            self.database.write()
        }
    }
    
    func testDelete() {
        measureMetrics(performanceMetrics, automaticallyStartMeasuring: false) {
            self.saveData()
            
            self.measure {
                self.database.deleteAll(OtherData)
            }
            
            self.database.write()
        }
    }
    
    private func saveData() {
        (0..<PerformanceTest.OtherDataCount).forEach {
            database.save(OtherData(id: nil, text: String($0)))
        }
    }
    
    private func saveDataWithId() {
        (0..<PerformanceTest.OtherDataWithIdCount).forEach {

            database.save(OtherData(id: $0, text: String($0)))
        }
    }
    
    private func saveComplex() {
        let otherData = OtherData(id: nil, text: "")
        let data = Data(id: nil, number: 0, optionalNumber: 0, numbers: [1, 1, 2], text: "", optionalString: nil,
             float: 0, double: 0, bool: false, relation: otherData,
             arrayWithRelation: (0..<PerformanceTest.RelationsCount).map { _ in otherData }, readOnly: "")
        (0..<PerformanceTest.DataCount).forEach { _ in
            database.save(data)
        }
    }
}