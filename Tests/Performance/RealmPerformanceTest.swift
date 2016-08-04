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
    
    private var realm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: String(RealmPerformanceTest)))
    
    override func setUp() {
        super.setUp()
        
        try! realm.write {
            realm.deleteAll()
        }
    }
    
    func testInit() {
        measureBlock {
            let _ = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: String(RealmPerformanceTest) + "testInit"))
        }
    }
    
    func testSave() {
        measureMetrics(performanceMetrics, automaticallyStartMeasuring: false) {
            try! self.realm.write {
                self.measure {
                    self.saveData()
                }
                
                self.realm.deleteAll()
            }
        }
    }
    
    func testSaveWithId() {
        measureMetrics(performanceMetrics, automaticallyStartMeasuring: false) {
            try! self.realm.write {
                self.measure {
                    self.saveData(withId: true)
                }
                
                self.realm.deleteAll()
            }
        }
    }
    
    func testSaveComplex() {
        measureMetrics(performanceMetrics, automaticallyStartMeasuring: false) {
            try! self.realm.write {
                self.measure {
                    self.saveComplex()
                }
                
                self.realm.deleteAll()
            }
        }
    }
    
    func testUpdate() {
        try! self.realm.write {
            saveComplex()
        }
        let objects = self.realm.objects(Torch_Data)
        measureMetrics(performanceMetrics, automaticallyStartMeasuring: false) {
            self.realm.beginWrite()
            
            self.measure {
                objects.forEach {
                    self.updateData($0)
                }
            }
            
            self.realm.cancelWrite()
        }
    }
    
    func testLoad() {
        try! realm.write {
            saveData()
        }
        
        measureBlock {
            let _ = Array(self.realm.objects(Torch_OtherData))
        }
    }
    
    func testRollback() {
        measureMetrics(performanceMetrics, automaticallyStartMeasuring: false) {
            self.realm.beginWrite()
            self.saveData()
            
            self.measure {
                self.realm.cancelWrite()
            }
        }
    }
    
    func testWrite() {
        measureMetrics(performanceMetrics, automaticallyStartMeasuring: false) {
            self.realm.beginWrite()
            self.saveData()
            
            self.measure {
                try! self.realm.commitWrite()
            }
            
            try! self.realm.write {
                self.realm.deleteAll()
            }
        }
    }
    
    func testDelete() {
        measureMetrics(performanceMetrics, automaticallyStartMeasuring: false) {
            try! self.realm.write {
                self.saveData()
                
                self.measure {
                    self.realm.deleteAll()
                }
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
            otherData.torch_text = String(index)
            data.torch_relation = otherData
            (0..<PerformanceTest.RelationsCount).forEach { j in
                let otherData = Torch_OtherData()
                otherData.id = PerformanceTest.DataCount + PerformanceTest.RelationsCount * i + j
                otherData.torch_text = String(index)
                data.torch_arrayWithRelation.append(otherData)
            }
            data.torch_readOnly = ""
            realm.add(data)
        }
    }
    
    private func updateData(data: Torch_Data) {
        data.torch_number = 0
        data.torch_optionalNumber.value = nil
        
        let numbers = [Torch_Data_numbers(), Torch_Data_numbers(), Torch_Data_numbers()]
        numbers[0].value = 1
        numbers[1].value = 1
        numbers[2].value = 2
        data.torch_numbers = List(numbers)
    }
}