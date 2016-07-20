//
//  TorchTest.swift
//  Torch
//
//  Created by Filip Dolnik on 19.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import XCTest
import CoreData
@testable import Torch

class TorchTest: XCTestCase {
    
    private var torch: UnsafeTorch!
    
    override func setUp() {
        super.setUp()
        
        let modelURL =  NSBundle(forClass: TorchTest.self).URLForResource("TorchTests", withExtension: "momd")!
        let managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL)!
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        try! coordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil)
        torch = UnsafeTorch(persistentStoreCoordinator: coordinator)
    }
    
    func testSave() {
        saveData()
        
        let data: [Data] = torch.load(Data.self)
        XCTAssertEqual(data.count, 3)
        XCTAssertEqual(data.filter { (x: Data) in x.id == 0 && x.x == "a" && x.y == 10 }.count, 1)
        XCTAssertEqual(data.filter { (x: Data) in x.id == 10 && x.x == "b" && x.y == 30 }.count, 1)
        XCTAssertEqual(data.filter { (x: Data) in x.id == 11 && x.x == "c" && x.y == 100 }.count, 1)
    }
    
    
    func testPredicate() {
        saveData()
        
        let loadedA: [Data] = torch.load(Data.self, where: Data.id.equalTo(0))
        XCTAssertEqual(loadedA.count, 1)
        XCTAssertEqual(loadedA.first?.x, "a")
    }
    
    private func saveData() {
        var a = Data(id: nil, x: "a", y: 10)
        var b = Data(id: 10, x: "b", y: 30)
        var c = Data(id: nil, x: "c", y: 100)
        
        torch.write {
            torch.save(&a).save(&b).save(&c)
        }
    }
}

struct Data: TorchEntity {
    
    var id: Int?
    let x: String
    let y: Int
}

extension Data {
    
    static let id = OptionalProperty<Data, Int>(name: "id")
    static let x = Property<Data, String>(name: "x")
    static let y = Property<Data, Int>(name: "y")
    
    init(fromManagedObject object: NSManagedObject) {
        id = object.valueForKey("id") as! Int?
        x = object.valueForKey("x") as! String
        y = object.valueForKey("y") as! Int
    }
    
    func updateManagedObject(object: NSManagedObject) {
        object.setValue(id, forKey: "id")
        object.setValue(x, forKey: "x")
        object.setValue(y, forKey: "y")
    }
}