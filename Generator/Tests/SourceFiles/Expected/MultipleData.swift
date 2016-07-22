// MARK: - Torch entity extensions generated from file: ../../Tests/SourceFiles/MultipleData.swift

import Torch
import CoreData

extension Data {
    
    static var torch_name: String {
        return "TorchEntity.Data"
    }
    
    static let id = Torch.TorchProperty<Data, Int?>(name: "id")
    
    init(fromManagedObject object: Torch.NSManagedObjectWrapper) throws {
        id = object.getValue(Data.id)
    }
    
    mutating func torch_updateManagedObject(object: Torch.NSManagedObjectWrapper) throws {
        object.setValue(id, for: Data.id)
    }
    
    static func torch_describeEntity(to registry: Torch.EntityRegistry) {
        registry.description(of: Data.self)
    }
    
    static func torch_describeProperties(to registry: Torch.PropertyRegistry) {
        registry.description(of: Data.id)
    }
}

extension Data2 {
    
    static var torch_name: String {
        return "TorchEntity.Data2"
    }
    
    static let id = Torch.TorchProperty<Data2, Int?>(name: "id")
    
    init(fromManagedObject object: Torch.NSManagedObjectWrapper) throws {
        id = object.getValue(Data2.id)
    }
    
    mutating func torch_updateManagedObject(object: Torch.NSManagedObjectWrapper) throws {
        object.setValue(id, for: Data2.id)
    }
    
    static func torch_describeEntity(to registry: Torch.EntityRegistry) {
        registry.description(of: Data2.self)
    }
    
    static func torch_describeProperties(to registry: Torch.PropertyRegistry) {
        registry.description(of: Data2.id)
    }
}
