// MARK: - Torch entity extensions generated from file: ../../Tests/SourceFiles/MultipleData.swift

import Torch
import CoreData

internal extension Data {

    internal static var torch_name: String {
        return "UserProject.Data"
    }

    internal static let id = Torch.TorchProperty<Data, Int?>(name: "id")

    internal init(fromManagedObject object: Torch.NSManagedObjectWrapper) throws {
        id = object.getValue(Data.id)
    }

    internal mutating func torch_updateManagedObject(object: Torch.NSManagedObjectWrapper) throws {
        object.setValue(id, for: Data.id)
    }

    internal static func torch_describeEntity(to registry: Torch.EntityRegistry) {
        registry.description(of: Data.self)
    }

    internal static func torch_describeProperties(to registry: Torch.PropertyRegistry) {
        registry.description(of: Data.id)
    }
}

internal extension Data2 {

    internal static var torch_name: String {
        return "UserProject.Data2"
    }

    internal static let id = Torch.TorchProperty<Data2, Int?>(name: "id")

    internal init(fromManagedObject object: Torch.NSManagedObjectWrapper) throws {
        id = object.getValue(Data2.id)
    }

    internal mutating func torch_updateManagedObject(object: Torch.NSManagedObjectWrapper) throws {
        object.setValue(id, for: Data2.id)
    }

    internal static func torch_describeEntity(to registry: Torch.EntityRegistry) {
        registry.description(of: Data2.self)
    }

    internal static func torch_describeProperties(to registry: Torch.PropertyRegistry) {
        registry.description(of: Data2.id)
    }
}

internal struct UserProjectEntityBundle: Torch.TorchEntityBundle {
    internal let entityTypes: [Torch.TorchEntity.Type] = [
            Data.self,
            Data2.self,
        ]

    internal init() { }
}
