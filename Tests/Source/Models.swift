//
//  Models.swift
//  Torch
//
//  Created by Filip Dolnik on 22.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Torch

struct Data: TorchEntity {
    var id: Int?
    
    var number: Int
    var optionalNumber: Int?
    var numbers: [Int]
    
    var text: String
    var float: Float
    var double: Double
    var bool: Bool
    
    var set: Set<Int>
    
    var relation: OtherData
    var optionalRelation: OtherData?
    var arrayWithRelation: [OtherData]
    var manualEntityRelation: ManualData
    
    let readOnly: String
}

struct OtherData: TorchEntity {
    var id: Int?
    var text: String
}

enum ManualData: ManualTorchEntity {
    case Test(id: Int?, text: String)
}

extension ManualData {
    static var torch_name: String {
        return "TorchEntity.ManualData"
    }

    static let id = Torch.TorchProperty<ManualData, Int?>(name: "id")
    static let text = Torch.TorchProperty<ManualData, String>(name: "text")

    var id: Int? {
        get {
            switch self {
            case .Test(let id, _):
                return id
            }
        }
        set {
            switch self {
            case .Test(_, let text):
                self = .Test(id: newValue, text: text)
            }
        }
    }

    init(fromManagedObject object: NSManagedObjectWrapper) throws {
        let id = object.getValue(ManualData.id)
        let text = object.getValue(ManualData.text)

        self = .Test(id: id, text: text)
    }

    mutating func torch_updateManagedObject(object: Torch.NSManagedObjectWrapper) throws {
        if case .Test(let id, let text) = self {
            object.setValue(id, for: ManualData.id)
            object.setValue(text, for: ManualData.text)
        }
    }

    static func torch_describeEntity(to registry: Torch.EntityRegistry) {
        registry.description(of: ManualData.self)
    }

    static func torch_describeProperties(to registry: Torch.PropertyRegistry) {
        registry.description(of: ManualData.id)
        registry.description(of: ManualData.text)
    }
}
