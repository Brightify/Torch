// MARK: - Torch entity extensions generated from file: ../../Tests/SourceFiles/Directory/Data.swift

import Torch
import RealmSwift

import Foundation
import UIKit

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
