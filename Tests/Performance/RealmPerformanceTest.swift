//
//  RealmPerformanceTest.swift
//  Torch
//
//  Created by Filip Dolnik on 29.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import XCTest
import RealmSwift

class RealmPerformanceTest: XCTestCase {
    
    private var realm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: String(describing: RealmPerformanceTest.self)))
    
    override func setUp() {
        super.setUp()
        
        try! realm.write {
            realm.deleteAll()
        }
    }
    
    func testInit() {
        measure {
            let _ = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: String(describing: RealmPerformanceTest.self) + "testInit"))
        }
    }
    
    func testSave() {
        measureMetrics(performanceMetrics, automaticallyStartMeasuring: false) {
            try! self.realm.write {
                self.startMeasuring()
                self.saveData()
                self.stopMeasuring()
                
                self.realm.deleteAll()
            }
        }
    }
    
    func testSaveWithId() {
        measureMetrics(performanceMetrics, automaticallyStartMeasuring: false) {
            try! self.realm.write {
                self.startMeasuring()
                self.saveData(withId: true)
                self.stopMeasuring()
                
                self.realm.deleteAll()
            }
        }
    }
    
    func testSaveComplex() {
        measureMetrics(performanceMetrics, automaticallyStartMeasuring: false) {
            try! self.realm.write {
                self.startMeasuring()
                self.saveComplex()
                self.stopMeasuring()
                
                self.realm.deleteAll()
            }
        }
    }
    
    func testUpdate() {
        try! self.realm.write {
            saveComplex()
        }
        let objects = self.realm.objects(Torch_Data.self)
        measureMetrics(performanceMetrics, automaticallyStartMeasuring: false) {
            self.realm.beginWrite()
            
            self.startMeasuring()
            objects.forEach {
                self.updateData($0)
            }
            self.stopMeasuring()
            
            self.realm.cancelWrite()
        }
    }
    
    func testLoad() {
        try! realm.write {
            saveData()
        }
        
        measure {
            let _ = Array(self.realm.objects(Torch_OtherData.self))
        }
    }
    
    func testRollback() {
        measureMetrics(performanceMetrics, automaticallyStartMeasuring: false) {
            self.realm.beginWrite()
            self.saveData()
            
            self.startMeasuring()
            self.realm.cancelWrite()
            self.stopMeasuring()
        }
    }
    
    func testWrite() {
        measureMetrics(performanceMetrics, automaticallyStartMeasuring: false) {
            self.realm.beginWrite()
            self.saveData()
            
            self.startMeasuring()
            try! self.realm.commitWrite()
            self.stopMeasuring()
            
            try! self.realm.write {
                self.realm.deleteAll()
            }
        }
    }
    
    func testDelete() {
        measureMetrics(performanceMetrics, automaticallyStartMeasuring: false) {
            try! self.realm.write {
                self.saveData()
                
                self.startMeasuring()
                self.realm.deleteAll()
                self.stopMeasuring()
            }
        }
    }
    
    private func saveData(withId update: Bool = false) {
        (0..<(update ? PerformanceTest.OtherDataWithIdCount : PerformanceTest.OtherDataCount)).forEach {
            let data = Torch_OtherData()
            data.id = $0
            data.torch_text = String($0)
            realm.add(data, update: update)
        }
    }
    
    private func saveComplex() {
        (0..<PerformanceTest.DataCount).forEach { i in
            let data = Torch_Data()
            data.id = i
            updateData(data)
            data.torch_text = ""
            data.torch_optionalString = nil
            data.torch_float = 0
            data.torch_double = 0
            data.torch_bool = false
            
            let otherData = Torch_OtherData()
            otherData.id = i
            otherData.torch_text = String(describing: index)
            data.torch_relation = otherData
            (0..<PerformanceTest.RelationsCount).forEach { j in
                let otherData = Torch_OtherData()
                otherData.id = PerformanceTest.DataCount + PerformanceTest.RelationsCount * i + j
                otherData.torch_text = String(describing: index)
                data.torch_arrayWithRelation.append(otherData)
            }
            data.torch_readOnly = ""
            realm.add(data)
        }
    }
    
    private func updateData(_ data: Torch_Data) {
        data.torch_number = 0
        data.torch_optionalNumber.value = nil
        
        let numbers = [Torch_Data_numbers(), Torch_Data_numbers(), Torch_Data_numbers()]
        numbers[0].value = 1
        numbers[1].value = 1
        numbers[2].value = 2
        data.torch_numbers = List(numbers)
    }
}
