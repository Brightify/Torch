// MARK: - Torch entity extensions generated from file: ../../Tests/SourceFiles/Directory/Data.swift

import Torch
import RealmSwift

internal extension Data {

    internal static let id = Torch.Property<Data, Int?>(name: "id")

    internal init(fromManagedObject object: Torch_Data) {
        id = Torch.Utils.toValue(object.id)
    }

    internal mutating func torch_updateManagedObject(object: Torch_Data, database: Torch.Database) {
    }

    internal static func torch_deleteValueTypeWrappers(object: Torch_Data, @noescape deleteFunction: (RealmSwift.Object) -> Void) {
    }
}

internal class Torch_Data: RealmSwift.Object, Torch.ManagedObject {
    internal dynamic var id = Int()

    internal override static func primaryKey() -> String? {
        return "id"
    }
}

// MARK: - Torch entity extensions generated from file: ../../Tests/SourceFiles/Directory/SecondDirectory/Data2.swift

import Torch
import RealmSwift

public extension Data2 {

    public static let id = Torch.Property<Data2, Int?>(name: "id")

    public init(fromManagedObject object: Torch_Data2) {
        id = Torch.Utils.toValue(object.id)
    }

    public mutating func torch_updateManagedObject(object: Torch_Data2, database: Torch.Database) {
    }

    public static func torch_deleteValueTypeWrappers(object: Torch_Data2, @noescape deleteFunction: (RealmSwift.Object) -> Void) {
    }
}

public class Torch_Data2: RealmSwift.Object, Torch.ManagedObject {
    public dynamic var id = Int()

    public override static func primaryKey() -> String? {
        return "id"
    }
}
