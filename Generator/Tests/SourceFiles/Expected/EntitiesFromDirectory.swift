// MARK: - Torch entity extensions generated from file: ../../Tests/SourceFiles/Directory/Data.swift

import Torch
import CoreData

internal extension Data {

    internal static var torch_name: String {
        return "UserProject_Data"
    }

    internal static let id = Torch.Property<Data, Int?>(name: "id")

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

// MARK: - Torch entity extensions generated from file: ../../Tests/SourceFiles/Directory/SecondDirectory/Data2.swift

import Torch
import CoreData

public extension Data2 {

    public static var torch_name: String {
        return "UserProject_Data2"
    }

    public static let id = Torch.Property<Data2, Int?>(name: "id")

    public init(fromManagedObject object: Torch.NSManagedObjectWrapper) throws {
        id = object.getValue(Data2.id)
    }

    public mutating func torch_updateManagedObject(object: Torch.NSManagedObjectWrapper) throws {
        object.setValue(id, for: Data2.id)
    }

    public static func torch_describeEntity(to registry: Torch.EntityRegistry) {
        registry.description(of: Data2.self)
    }

    public static func torch_describeProperties(to registry: Torch.PropertyRegistry) {
        registry.description(of: Data2.id)
    }
}

public struct UserProjectEntityBundle: Torch.TorchEntityBundle {
    public let entityTypes: [Torch.TorchEntity.Type] = [
            Data.self,
            Data2.self,
        ]

    public init() { }
}
