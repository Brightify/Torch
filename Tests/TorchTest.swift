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
    
    func testSave() {
        let modelURL =  NSBundle(forClass: TorchTest.self).URLForResource("TorchTests", withExtension: "momd")!
        let managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL)!
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        try! coordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil)
        let torch = UnsafeTorch(persistentStoreCoordinator: coordinator)

        var a = Data(id: nil, x: "a", y: 10)
        var b = Data(id: 10, x: "b", y: 30)
        var c = Data(id: nil, x: "c", y: 100)
        
        torch.write {
            torch.save(&a).save(&b).save(&c)
        }
        
        let data: [Data] = torch.load(Data.self)

        XCTAssertEqual(data.filter { (x: Data) in x.id == 0 && x.x == "a" && x.y == 10 }.count, 1)
        XCTAssertEqual(data.filter { (x: Data) in x.id == 10 && x.x == "b" && x.y == 30 }.count, 1)
        XCTAssertEqual(data.filter { (x: Data) in x.id == 11 && x.x == "c" && x.y == 100 }.count, 1)
    }
}

struct Data: TorchEntity {
    
    var id: Int?
    let x: String
    let y: Int
    
}

extension Data {
    
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