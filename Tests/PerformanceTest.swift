//
//  PerformanceTest.swift
//  Torch
//
//  Created by Filip Dolnik on 25.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import XCTest
import Torch

class PerformanceTest: XCTestCase {

    static let OtherDataCount = 10000
    static let OtherDataWithIdCount = 1000
    static let DataCount = 500
    static let RelationsCount = 10
    
    private var database: UnsafeDatabase!
    
    override func setUp() {
        super.setUp()
        
        initDatabase()
    }
    
    func testInit() {
        measureBlock {
            self.initDatabase()
        }
    }
    
    func testSave() {
        measureMetrics(performanceMetrics, automaticallyStartMeasuring: false) {
            self.measure {
                self.saveData()
            }
            
            self.database.deleteAll(OtherData.self)
        }
    }
    
    func testSaveWithId() {
        measureMetrics(performanceMetrics, automaticallyStartMeasuring: false) {
            self.measure {
                self.saveDataWithId()
            }
            
            self.database.deleteAll(OtherData.self)
        }
    }

    /*
    func testSaveComplex() {
        measureMetrics(performanceMetrics, automaticallyStartMeasuring: false) {
            self.measure {
                self.saveComplex()
            }
            
            self.database.deleteAll(OtherData.self)
            self.database.deleteAll(Data.self)
        }
    }*/
    
    func testLoad() {
        saveData()
        
        measureBlock {
            self.database.load(OtherData.self)//, where: OtherData.id > 40000)
        }
    }
    
    func testDelete() {        
        measureMetrics(performanceMetrics, automaticallyStartMeasuring: false) {
            self.saveData()
            
            self.measure {
                self.database.deleteAll(OtherData.self)
            }
        }
    }
    
    private func initDatabase() {
        database = try! Database(storage: .Memory, bundle: TorchTestsEntityBundle()).unsafeInstance()
    }
    
    private func saveData() {
        (0..<PerformanceTest.OtherDataCount).forEach {
            database.save(OtherData(id: nil, text: String($0)))
        }
    }
    
    private func saveDataWithId() {
        (0..<PerformanceTest.OtherDataWithIdCount).forEach {
            database.save(OtherData(id: $0 as Int, text: String($0)))
        }
    }
    /*
    private func saveComplex() {
        let otherData = OtherData(id: nil, text: "")
        let manualData = ManualData.Root(id: nil, text: "")
        let data = Data(id: nil, number: 0, optionalNumber: 0, numbers: [1, 1, 2], text: "",
             float: 0, double: 0, bool: false, set: [1, 2], relation: otherData, optionalRelation: nil,
             arrayWithRelation: (0..<PerformanceTest.RelationsCount).map { _ in otherData }, manualEntityRelation: manualData, readOnly: "")
        (0..<PerformanceTest.DataCount).forEach { _ in
            database.save(data)
        }
    }*/
}