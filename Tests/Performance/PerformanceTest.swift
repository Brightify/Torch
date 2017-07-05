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
        measure {
            let _ = try! Database(configuration: Realm.Configuration(inMemoryIdentifier: String(describing: PerformanceTest.self) + "testInit"))
        }
    }
    
    func testSave() {
        measureMetrics(performanceMetrics, automaticallyStartMeasuring: false) {
            self.startMeasuring()
            self.saveData()
            self.stopMeasuring()

            self.database.deleteAll(OtherData.self)
        }
    }
    
    func testSaveWithId() {
        measureMetrics(performanceMetrics, automaticallyStartMeasuring: false) {
            self.startMeasuring()
            self.saveDataWithId()
            self.stopMeasuring()
            
            self.database.deleteAll(OtherData.self)
        }
    }
    
    func testSaveComplex() {
        measureMetrics(performanceMetrics, automaticallyStartMeasuring: false) {
            self.startMeasuring()
            self.saveComplex()
            self.stopMeasuring()

            self.database.write { _ in
                self.database.deleteAll(OtherData.self)
                self.database.deleteAll(Data.self)
            }
        }
    }
    
    func testUpdate() {
        self.saveComplex()
        let objects = database.load(Data.self)
        measureMetrics(performanceMetrics, automaticallyStartMeasuring: false) {
            self.database.write { rollback in
                self.startMeasuring()
                for var object in objects {
                    object.number = 0
                    object.optionalNumber = nil
                    object.numbers = [1, 2, 3]
                    self.database.save(object)
                }

                self.stopMeasuring()

                rollback()
            }
        }
    }

    func testLoad() {
        saveData()
        
        measure {
            _ = self.database.load(OtherData.self)
        }
    }
    
    func testRollback() {
        measureMetrics(performanceMetrics, automaticallyStartMeasuring: false) {
            self.database.write { rollback in
                self.saveData()

                self.startMeasuring()
                rollback()
            }
            self.stopMeasuring()
        }
    }

    func testWrite() {
        measureMetrics(performanceMetrics, automaticallyStartMeasuring: false) {
            self.saveData()
            
            self.startMeasuring()
            self.database.write { _ in }
            self.stopMeasuring()
            
            self.database.deleteAll(OtherData.self)
        }
    }
    
    func testDelete() {
        measureMetrics(performanceMetrics, automaticallyStartMeasuring: false) {
            self.saveData()
            
            self.startMeasuring()
            self.database.deleteAll(OtherData.self)
            self.stopMeasuring()
        }
    }
    
    private func saveData() {
        (0..<PerformanceTest.OtherDataCount).forEach {
            database.save(OtherData(id: nil, text: String($0)))
        }
    }
    
    private func saveDataWithId() {
        (0..<PerformanceTest.OtherDataWithIdCount).forEach {
            database.save(OtherData(id: $0, text: String(describing: $0)))
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
