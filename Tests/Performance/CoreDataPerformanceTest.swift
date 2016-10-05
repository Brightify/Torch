//
//  CoreDataPerformanceTest.swift
//  Torch
//
//  Created by Filip Dolnik on 25.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import XCTest
import CoreData

class CoreDataPerformanceTest: XCTestCase {
    
    private var context: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        
        initDatabase()
    }
    
    func testInit() {
        measure {
            self.initDatabase()
        }
    }
    
    func testSave() {
        measureMetrics(performanceMetrics, automaticallyStartMeasuring: false) {
            self.startMeasuring()
            self.saveData()
            self.stopMeasuring()
            
            self.deleteAll(Core_OtherData.Name)
            try! self.context.save()
        }
    }
    
    func testSaveWithId() {
        measureMetrics(performanceMetrics, automaticallyStartMeasuring: false) {
            self.startMeasuring()
            self.saveDataWithId()
            self.stopMeasuring()
            
            self.deleteAll(Core_OtherData.Name)
            try! self.context.save()
        }
    }
    
    func testSaveComplex() {
        measureMetrics(performanceMetrics, automaticallyStartMeasuring: false) {
            self.startMeasuring()
            self.saveComplex()
            self.stopMeasuring()
            
            self.deleteAll(Core_Data.Name)
            self.deleteAll(Core_OtherData.Name)
            try! self.context.save()
        }
    }
    
    func testUpdate() {
        saveComplex()
        try! context.save()
        let request = NSFetchRequest<Core_Data>(entityName: Core_Data.Name)
        let objects = try! self.context.fetch(request)
        measureMetrics(performanceMetrics, automaticallyStartMeasuring: false) {
            self.startMeasuring()
            objects.forEach {
                $0.setValue(0, forKey: "number")
                $0.setValue(nil, forKey: "optionalNumber")
                $0.setValue(NSArray(array: [1, 2, 3]) as! [NSNumber], forKey: "numbers")
            }
            self.stopMeasuring()
            
            self.context.rollback()
        }
    }
    
    func testLoad() {
        saveData()
        
        measure {
            let request = NSFetchRequest<Core_OtherData>(entityName: Core_OtherData.Name)
            let objects = try! self.context.fetch(request)
            let _ = objects.map { OtherData(id: $0.value(forKey: "id") as? Int, text: $0.value(forKey: "text") as! String) }
        }
    }

    func testRollback() {
        measureMetrics(performanceMetrics, automaticallyStartMeasuring: false) {
            self.saveData()
            
            self.startMeasuring()
            self.context.rollback()
            self.stopMeasuring()
        }
    }

    func testWrite() {
        measureMetrics(performanceMetrics, automaticallyStartMeasuring: false) {
            self.saveData()
            
            self.startMeasuring()
            try! self.context.save()
            self.stopMeasuring()
            
            self.deleteAll(Core_OtherData.Name)
            try! self.context.save()
        }
    }

    func testDelete() {
        measureMetrics(performanceMetrics, automaticallyStartMeasuring: false) {
            self.saveData()
            
            self.startMeasuring()
            self.deleteAll(Core_OtherData.Name)
            self.stopMeasuring()
            
            try! self.context.save()
        }
    }
    
    private func initDatabase() {
        let modelURL = Bundle(for: CoreDataPerformanceTest.self).url(forResource: "CoreDataModel", withExtension: "momd")!
        let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)!
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        try! coordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
        
        context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
    }
    
    private func saveData() {
        let description = NSEntityDescription.entity(forEntityName: Core_OtherData.Name, in: context)!
        (0..<PerformanceTest.OtherDataCount).forEach {
            let otherData = Core_OtherData(entity: description, insertInto: context)
            otherData.id = NSNumber(value: $0)
            otherData.text = String($0)
        }
    }
    
    private func saveDataWithId() {
        let description = NSEntityDescription.entity(forEntityName: Core_OtherData.Name, in: context)!
        
        (0..<PerformanceTest.OtherDataWithIdCount).forEach {
                let request = NSFetchRequest<Core_OtherData>(entityName: Core_OtherData.Name)

            request.predicate = NSPredicate(format: "id = \($0)")
            request.fetchLimit = 1
            let otherData: Core_OtherData
            if let object = (try! self.context.fetch(request)).first {
                otherData = object
            } else {
                otherData = Core_OtherData(entity: description, insertInto: context)
                otherData.id = NSNumber(value: $0)
            }
            otherData.text = String($0)
        }
    }
    
    private func saveComplex() {
        let dataDescription = NSEntityDescription.entity(forEntityName: Core_Data.Name, in: context)!
        let otherDescription = NSEntityDescription.entity(forEntityName: Core_OtherData.Name, in: context)!
        (0..<PerformanceTest.DataCount).forEach {
            let otherData = Core_OtherData(entity: otherDescription, insertInto: context)
            otherData.id = NSNumber(value: $0)
            otherData.text = String($0)
            
            let data = Core_Data(entity: dataDescription, insertInto: context)
            data.id = NSNumber(value: $0)
            data.number = 0
            data.numbers = NSArray(array: [1, 1, 2]) as! [NSNumber]
            data.text = ""
            data.float = 0
            data.double = 0
            data.bool = false
            data.relation = otherData
            data.arrayWithRelation = NSOrderedSet(array: (0..<PerformanceTest.RelationsCount).map {
                let otherData = Core_OtherData(entity: otherDescription, insertInto: context)
                otherData.text = String($0)
                return otherData
            })
            data.readOnly = ""
        }
    }
    
    private func deleteAll(_ name: String) {
        let request = NSFetchRequest<NSManagedObject>(entityName: name)
        (try! context.fetch(request)).forEach {
            context.delete($0)
        }
    }
}

@objc(Core_Data)
class Core_Data: NSManagedObject {
    
    static let Name = "Core_Data"
    
    @NSManaged var id: NSNumber
    @NSManaged var number: NSNumber
    @NSManaged var optionalNumber: NSNumber
    @NSManaged var numbers: [NSNumber]
    
    @NSManaged var text: String
    @NSManaged var float: NSNumber
    @NSManaged var double: NSNumber
    @NSManaged var bool: NSNumber
    
    @NSManaged var relation: Core_OtherData
    @NSManaged var arrayWithRelation: NSOrderedSet
    
    @NSManaged var readOnly: String
}

@objc(Core_OtherData)
class Core_OtherData: NSManagedObject {
    
    static let Name = "Core_OtherData"
    
    @NSManaged var id: NSNumber
    @NSManaged var text: String
}
