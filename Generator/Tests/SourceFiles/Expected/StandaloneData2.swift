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
