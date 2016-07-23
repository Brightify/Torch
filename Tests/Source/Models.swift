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
    case Root(id: Int?, text: String)
    indirect case Node(id: Int?, text: String, parent: ManualData)
}

extension ManualData {
    static var torch_name: String {
        return "TorchEntity.ManualData"
    }

    static let id = Torch.TorchProperty<ManualData, Int?>(name: "id")
    static let text = Torch.TorchProperty<ManualData, String>(name: "text")
    static let parent = Torch.TorchProperty<ManualData, ManualData?>(name: "parent")

    var id: Int? {
        get {
            switch self {
            case .Node(let id, _, _):
                return id
            case .Root(let id, _):
                return id
            }
        }
        set {
            switch self {
            case .Node(_, let text, let parent):
                self = .Node(id: newValue, text: text, parent: parent)
            case .Root(_, let text):
                self = .Root(id: newValue, text: text)
            }
        }
    }

    init(fromManagedObject object: NSManagedObjectWrapper) throws {
        let id = object.getValue(ManualData.id)
        let text = object.getValue(ManualData.text)
        if let parent = try object.getValue(ManualData.parent) {
            self = .Node(id: id, text: text, parent: parent)
        } else {
            self = .Root(id: id, text: text)
        }
    }

    mutating func torch_updateManagedObject(object: Torch.NSManagedObjectWrapper) throws {
        switch self {
        case .Node(let id, let text, let parent):
            var mutableParent = Optional(parent)
            object.setValue(id, for: ManualData.id)
            object.setValue(text, for: ManualData.text)
            try object.setValue(&mutableParent, for: ManualData.parent)
            if let newParent = mutableParent {
                self = .Node(id: id, text: text, parent: newParent)
            } else {
                self = .Root(id: id, text: text)
            }

        case .Root(let id, let text):
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
        registry.description(of: ManualData.parent)
    }
}
