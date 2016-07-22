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
        let a = Data(id: nil, x: "a", y: 10, otherDatum: OtherData(id: nil, name: "OtherData1"), otherData: [])
        let b = Data(id: 10, x: "b", y: 30, otherDatum: OtherData(id: nil, name: "OtherData2"), otherData: [])
        let c = Data(id: nil, x: "c", y: 100, otherDatum: OtherData(id: nil, name: "OtherData3"), otherData: [])

        database.save(a, b, c).write()
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

    static let id = TorchProperty<Data, Int?>(name: "id")
    static let x = TorchProperty<Data, String>(name: "x")
    static let y = TorchProperty<Data, Int>(name: "y")
    static let otherDatum = TorchProperty<Data, OtherData>(name: "otherDatum")
    static let otherData = TorchProperty<Data, [OtherData]>(name: "otherData")

    init(fromManagedObject object: NSManagedObjectWrapper) throws {
        id = object.getValue(Data.id)
        x = object.getValue(Data.x)
        y = object.getValue(Data.y)
        otherDatum = try object.getValue(Data.otherDatum)
        otherData = try object.getValue(Data.otherData)
    }

    mutating func torch_updateManagedObject(object: NSManagedObjectWrapper) throws {
        object.setValue(id, for: Data.id)
        object.setValue(x, for: Data.x)
        object.setValue(y, for: Data.y)
        try object.setValue(&otherDatum, for: Data.otherDatum)
        try object.setValue(&otherData, for: Data.otherData)
    }

    static func torch_describeEntity(to registry: EntityRegistry) {
        registry.description(of: Data.self)
    }
    
    static func torch_describeProperties(to registry: PropertyRegistry) {
        registry.description(of: Data.id)
        registry.description(of: Data.x)
        registry.description(of: Data.y)
        registry.description(of: Data.otherDatum)
        registry.description(of: Data.otherData)
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

    static let id = TorchProperty<OtherData, Int?>(name: "id")
    static let name = TorchProperty<OtherData, String?>(name: "name")

    init(fromManagedObject object: NSManagedObjectWrapper) throws {
        id = object.getValue(OtherData.id)
        name = object.getValue(OtherData.name)
    }

    mutating func torch_updateManagedObject(object: NSManagedObjectWrapper) throws {
        object.setValue(id, for: OtherData.id)
        object.setValue(name, for: OtherData.name)
    }

    static func torch_describeEntity(to registry: EntityRegistry) {
        registry.description(of: OtherData.self)
    }
    
    static func torch_describeProperties(to registry: PropertyRegistry) {
        registry.description(of: OtherData.id)
        registry.description(of: OtherData.name)
    }
}