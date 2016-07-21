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
    
    private var database: UnsafeDatabase!
    
    override func setUp() {
        super.setUp()
        
        let inMemoryStore = StoreConfiguration(storeType: NSInMemoryStoreType, configuration: nil, storeURL: nil, options: nil)
        database = UnsafeDatabase(store: inMemoryStore, entities: Data.self, OtherData.self)
    }
    
    func testSave() {
        saveData()
        
        let data: [Data] = database.load(Data.self)
        XCTAssertEqual(data.count, 3)
        XCTAssertEqual(data.filter { (x: Data) in x.id == 0 && x.x == "a" && x.y == 10 }.count, 1)
        XCTAssertEqual(data.filter { (x: Data) in x.id == 10 && x.x == "b" && x.y == 30 }.count, 1)
        XCTAssertEqual(data.filter { (x: Data) in x.id == 11 && x.x == "c" && x.y == 100 }.count, 1)
    }
    
    
    func testPredicate() {
        saveData()
        
        let loadedA: [Data] = database.load(Data.self, where: Data.id.equalTo(0))
        XCTAssertEqual(loadedA.count, 1)
        XCTAssertEqual(loadedA.first?.x, "a")
    }
    
    private func saveData() {
        var a = Data(id: nil, x: "a", y: 10, otherDatum: OtherData(id: nil, name: "OtherData1"), otherData: [])
        var b = Data(id: 10, x: "b", y: 30, otherDatum: OtherData(id: nil, name: "OtherData2"), otherData: [])
        var c = Data(id: nil, x: "c", y: 100, otherDatum: OtherData(id: nil, name: "OtherData3"), otherData: [])

        database.write {
            database.save(&a).save(&b).save(&c)
        }
    }
}

struct Data: TorchEntity {
    var id: Int?
    var x: String
    var y: Int
    var otherDatum: OtherData
    var otherData: [OtherData]
}

extension Data {

    static var torch_name: String {
        return "TorchRegistration.Data"
    }

    static var torch_properties: [AnyProperty<Data>] {
        return [
            id.typeErased(),
            x.typeErased(),
            y.typeErased(),
            otherDatum.typeErased(),
            otherData.typeErased()
        ]
    }

    static let id = ScalarProperty<Data, Int?>(name: "id")
    static let x = ScalarProperty<Data, String>(name: "x")
    static let y = ScalarProperty<Data, Int>(name: "y")
    static let otherDatum = ToOneRelationProperty<Data, OtherData>(name: "otherDatum")
    static let otherData = ToManyRelationProperty<Data, [OtherData]>(name: "otherData")

    init(fromManagedObject object: NSManagedObject, database: Database) throws {
        id = object.valueForKey("id") as! Int?
        x = object.valueForKey("x") as! String
        y = object.valueForKey("y") as! Int

        otherDatum = try OtherData(fromManagedObject: object.valueForKey("otherDatum") as! NSManagedObject, database: database)

        otherData = try (object.valueForKey("otherData") as! Set<NSManagedObject>).map { try OtherData(fromManagedObject: $0, database: database) }
    }

    mutating func torch_updateManagedObject(object: NSManagedObject, database: Database) throws {
        object.setValue(id, forKey: "id")
        object.setValue(x, forKey: "x")
        object.setValue(y, forKey: "y")
        object.setValue(try database.getManagedObject(for:  &otherDatum), forKey: "otherDatum")

        var newOtherData: [OtherData] = []
        var otherDataObjects = Set<NSManagedObject>()
        for d in otherData {
            var mutableD = d
            otherDataObjects.insert(try database.getManagedObject(for: &mutableD))
            newOtherData.append(mutableD)
        }
        otherData = newOtherData
        object.setValue(otherDataObjects, forKey: "otherData")
    }

    static func torch_describe(to registry: EntityRegistry) {
        registry.description(of: Data.self)
    }
}

struct OtherData: TorchEntity {
    var id: Int?
    var name: String?
}

extension OtherData {
    static var torch_name: String {
        return "TorchRegistration.OtherData"
    }

    static var torch_properties: [AnyProperty<OtherData>] {
        return [
            id.typeErased(),
            name.typeErased()
        ]
    }

    static let id = ScalarProperty<OtherData, Int?>(name: "id")
    static let name = ScalarProperty<OtherData, String?>(name: "name")

    init(fromManagedObject object: NSManagedObject, database: Database) throws {
        id = object.valueForKey("id") as! Int?
        name = object.valueForKey("name") as! String?
    }

    mutating func torch_updateManagedObject(object: NSManagedObject, database: Database) throws {
        object.setValue(id, forKey: "id")
        object.setValue(name, forKey: "name")
    }

    static func torch_describe(to registry: EntityRegistry) {
        registry.description(of: OtherData.self)
    }
}