// MARK: - Torch entity extensions generated from file: ../../Tests/SourceFiles/MultipleData.swift

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

internal extension Data2 {

    internal static let id = Torch.Property<Data2, Int?>(name: "id")

    internal init(fromManagedObject object: Torch_Data2) {
        id = Torch.Utils.toValue(object.id)
    }

    internal mutating func torch_updateManagedObject(object: Torch_Data2, database: Torch.Database) {
    }

    internal static func torch_deleteValueTypeWrappers(object: Torch_Data2, @noescape deleteFunction: (RealmSwift.Object) -> Void) {
    }
}

internal class Torch_Data2: RealmSwift.Object, Torch.ManagedObject {
    internal dynamic var id = Int()

    internal override static func primaryKey() -> String? {
        return "id"
    }
}
