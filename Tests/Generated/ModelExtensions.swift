//
//  ModelExtensions.swift
//  Torch
//
//  Created by Filip Dolnik on 22.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Torch
import CoreData

extension Data {
    
    static var torch_name: String {
        return "TorchEntity.Data"
    }
    
    static let id = Torch.TorchProperty<Data, Int?>(name: "id")
    static let number = Torch.TorchProperty<Data, Int>(name: "number")
    static let optionalNumber = Torch.TorchProperty<Data, Int?>(name: "optionalNumber")
    static let numbers = Torch.TorchProperty<Data, [Int]>(name: "numbers")
    static let text = Torch.TorchProperty<Data, String>(name: "text")
    static let float = Torch.TorchProperty<Data, Float>(name: "float")
    static let double = Torch.TorchProperty<Data, Double>(name: "double")
    static let bool = Torch.TorchProperty<Data, Bool>(name: "bool")
    static let relation = Torch.TorchProperty<Data, OtherData>(name: "relation")
    static let optionalRelation = Torch.TorchProperty<Data, OtherData?>(name: "optionalRelation")
    static let arrayWithRelation = Torch.TorchProperty<Data, [OtherData]>(name: "arrayWithRelation")
    static let readOnly = Torch.TorchProperty<Data, String>(name: "readOnly")
    
    init(fromManagedObject object: Torch.NSManagedObjectWrapper) throws {
        id = object.getValue(Data.id)
        number = object.getValue(Data.number)
        optionalNumber = object.getValue(Data.optionalNumber)
        numbers = object.getValue(Data.numbers)
        text = object.getValue(Data.text)
        float = object.getValue(Data.float)
        double = object.getValue(Data.double)
        bool = object.getValue(Data.bool)
        relation = try object.getValue(Data.relation)
        optionalRelation = try object.getValue(Data.optionalRelation)
        arrayWithRelation = try object.getValue(Data.arrayWithRelation)
        readOnly = object.getValue(Data.readOnly)
    }
    
    mutating func torch_updateManagedObject(object: Torch.NSManagedObjectWrapper) throws {
        object.setValue(id, for: Data.id)
        object.setValue(number, for: Data.number)
        object.setValue(optionalNumber, for: Data.optionalNumber)
        object.setValue(numbers, for: Data.numbers)
        object.setValue(text, for: Data.text)
        object.setValue(float, for: Data.float)
        object.setValue(double, for: Data.double)
        object.setValue(bool, for: Data.bool)
        try object.setValue(&relation, for: Data.relation)
        try object.setValue(&optionalRelation, for: Data.optionalRelation)
        try object.setValue(&arrayWithRelation, for: Data.arrayWithRelation)
        object.setValue(readOnly, for: Data.readOnly)
    }
    
    static func torch_describeEntity(to registry: Torch.EntityRegistry) {
        registry.description(of: Data.self)
    }
    
    static func torch_describeProperties(to registry: Torch.PropertyRegistry) {
        registry.description(of: Data.id)
        registry.description(of: Data.number)
        registry.description(of: Data.optionalNumber)
        registry.description(of: Data.numbers)
        registry.description(of: Data.text)
        registry.description(of: Data.float)
        registry.description(of: Data.double)
        registry.description(of: Data.bool)
        registry.description(of: Data.relation)
        registry.description(of: Data.optionalRelation)
        registry.description(of: Data.arrayWithRelation)
        registry.description(of: Data.readOnly)
    }
}

extension OtherData {
    
    static var torch_name: String {
        return "TorchEntity.OtherData"
    }
    
    static let id = Torch.TorchProperty<OtherData, Int?>(name: "id")
    static let text = Torch.TorchProperty<OtherData, String>(name: "text")
    
    init(fromManagedObject object: Torch.NSManagedObjectWrapper) throws {
        id = object.getValue(OtherData.id)
        text = object.getValue(OtherData.text)
    }
    
    mutating func torch_updateManagedObject(object: Torch.NSManagedObjectWrapper) throws {
        object.setValue(id, for: OtherData.id)
        object.setValue(text, for: OtherData.text)
    }
    
    static func torch_describeEntity(to registry: Torch.EntityRegistry) {
        registry.description(of: OtherData.self)
    }
    
    static func torch_describeProperties(to registry: Torch.PropertyRegistry) {
        registry.description(of: OtherData.id)
        registry.description(of: OtherData.text)
    }
}
