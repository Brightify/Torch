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
        measureBlock {
            self.initDatabase()
        }
    }
    
    func testSave() {
        measureMetrics(performanceMetrics, automaticallyStartMeasuring: false) {
            self.measure {
                self.saveData()
            }
            
            self.deleteAll(Core_OtherData.Name)
            try! self.context.save()
        }
    }
    
    func testSaveWithId() {
        measureMetrics(performanceMetrics, automaticallyStartMeasuring: false) {
            self.measure {
                self.saveDataWithId()
            }
            
            self.deleteAll(Core_OtherData.Name)
            try! self.context.save()
        }
    }
    
    func testSaveComplex() {
        measureMetrics(performanceMetrics, automaticallyStartMeasuring: false) {
            self.measure {
                self.saveComplex()
            }
            
            self.deleteAll(Core_Data.Name)
            self.deleteAll(Core_OtherData.Name)
            try! self.context.save()
        }
    }
    
    
    func testLoad() {
        saveData()
        
        measureBlock {
            let request = NSFetchRequest(entityName: Core_OtherData.Name)
            request.predicate = NSPredicate(format: "id > 40000")
            let objects = try! self.context.executeFetchRequest(request) as! [NSManagedObject]
            let _ = objects.map { OtherData(id: $0.valueForKey("id") as? Int, text: $0.valueForKey("text") as! String) }
        }
    }

    func testRollback() {
        measureMetrics(performanceMetrics, automaticallyStartMeasuring: false) {
            self.saveData()
            
            self.measure {
                self.context.rollback()
            }
        }
    }

    func testWrite() {
        measureMetrics(performanceMetrics, automaticallyStartMeasuring: false) {
            self.saveData()
            
            self.measure {
                try! self.context.save()
            }
            
            self.deleteAll(Core_OtherData.Name)
            try! self.context.save()
        }
    }

    func testDelete() {
        measureMetrics(performanceMetrics, automaticallyStartMeasuring: false) {
            self.saveData()
            
            self.measure {
                self.deleteAll(Core_OtherData.Name)
            }
            
            try! self.context.save()
        }
    }
    
    private func initDatabase() {
        let modelURL = NSBundle(forClass: CoreDataPerformanceTest.self).URLForResource("CoreDataModel", withExtension: "momd")!
        let managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL)!
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        try! coordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil)
        
        context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
    }
    
    private func saveData() {
        let description = NSEntityDescription.entityForName(Core_OtherData.Name, inManagedObjectContext: context)!
        (0..<PerformanceTest.OtherDataCount).forEach {
            let otherData = Core_OtherData(entity: description, insertIntoManagedObjectContext: context)
            otherData.id = $0
            otherData.text = String($0)
        }
    }
    
    private func saveDataWithId() {
        let description = NSEntityDescription.entityForName(Core_OtherData.Name, inManagedObjectContext: context)!
        
        (0..<PerformanceTest.OtherDataWithIdCount).forEach {
                let request = NSFetchRequest(entityName: Core_OtherData.Name)

            request.predicate = NSPredicate(format: "id = \($0)")
            request.fetchLimit = 1
            let otherData: Core_OtherData
            if let object = (try! self.context.executeFetchRequest(request) as! [Core_OtherData]).first {
                otherData = object
            } else {
                otherData = Core_OtherData(entity: description, insertIntoManagedObjectContext: context)
                otherData.id = $0
            }
            otherData.text = String($0)
        }
    }
    
    private func saveComplex() {
        let dataDescription = NSEntityDescription.entityForName(Core_Data.Name, inManagedObjectContext: context)!
        let otherDescription = NSEntityDescription.entityForName(Core_OtherData.Name, inManagedObjectContext: context)!
        (0..<PerformanceTest.DataCount).forEach {
            let otherData = Core_OtherData(entity: otherDescription, insertIntoManagedObjectContext: context)
            otherData.id = $0
            otherData.text = String($0)
            
            let data = Core_Data(entity: dataDescription, insertIntoManagedObjectContext: context)
            data.id = $0
            data.number = 0
            data.numbers = NSArray(array: [1, 1, 2]) as! [NSNumber]
            data.text = ""
            data.float = 0
            data.double = 0
            data.bool = false
            data.set = NSOrderedSet(array: [1, 2])
            data.relation = otherData
            data.relation2 = otherData
            data.arrayWithRelation = NSOrderedSet(array: (0..<PerformanceTest.RelationsCount).map {
                let otherData = Core_OtherData(entity: otherDescription, insertIntoManagedObjectContext: context)
                otherData.text = String($0)
                return otherData
            })
            data.readOnly = ""
        }
    }
    
    private func deleteAll(name: String) {
        let request = NSFetchRequest(entityName: name)
        (try! context.executeFetchRequest(request) as! [NSManagedObject]).forEach {
            context.deleteObject($0)
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
    @NSManaged var bool: Bool
    
    @NSManaged var set: NSOrderedSet
    
    @NSManaged var relation: Core_OtherData
    @NSManaged var optionalRelation: Core_OtherData
    @NSManaged var arrayWithRelation: NSOrderedSet
    @NSManaged var relation2: Core_OtherData
    
    @NSManaged var readOnly: String
}

@objc(Core_OtherData)
class Core_OtherData: NSManagedObject {
    
    static let Name = "Core_OtherData"
    
    @NSManaged var id: NSNumber
    @NSManaged var text: String
}