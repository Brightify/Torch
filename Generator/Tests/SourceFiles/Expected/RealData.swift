// MARK: - Torch entity extensions generated from file: ../../Tests/SourceFiles/RealData.swift

import Torch
import RealmSwift

internal extension Data {

    internal static let id = Torch.Property<Data, Int?>(name: "id")
    internal static let number = Torch.Property<Data, Int>(name: "number")
    internal static let optionalNumber = Torch.Property<Data, Int?>(name: "optionalNumber")
    internal static let numbers = Torch.Property<Data, [Int]>(name: "numbers")
    internal static let text = Torch.Property<Data, String>(name: "text")
    internal static let float = Torch.Property<Data, Float>(name: "float")
    internal static let double = Torch.Property<Data, Double>(name: "double")
    internal static let bool = Torch.Property<Data, Bool>(name: "bool")
    internal static let set = Torch.Property<Data, Set<Int>>(name: "set")
    internal static let relation = Torch.Property<Data, OtherData>(name: "relation")
    internal static let optionalRelation = Torch.Property<Data, OtherData?>(name: "optionalRelation")
    internal static let arrayWithRelation = Torch.Property<Data, [OtherData]>(name: "arrayWithRelation")
    internal static let readOnly = Torch.Property<Data, String>(name: "readOnly")

    internal init(fromManagedObject object: Torch_Data) {
        id = Torch.Utils.toValue(object.id)
        number = Torch.Utils.toValue(object.number)
        optionalNumber = Torch.Utils.toValue(object.optionalNumber)
        numbers = Torch.Utils.toValue(object.numbers)
        text = Torch.Utils.toValue(object.text)
        float = Torch.Utils.toValue(object.float)
        double = Torch.Utils.toValue(object.double)
        bool = Torch.Utils.toValue(object.bool)
        set = Torch.Utils.toValue(object.set)
        relation = Torch.Utils.toValue(object.relation)
        optionalRelation = Torch.Utils.toValue(object.optionalRelation)
        arrayWithRelation = Torch.Utils.toValue(object.arrayWithRelation)
        readOnly = Torch.Utils.toValue(object.readOnly)
    }

    internal mutating func torch_updateManagedObject(object: Torch_Data, database: Torch.Database) {
        Torch.Utils.updateManagedValue(&object.number, number)
        Torch.Utils.updateManagedValue(&object.optionalNumber, optionalNumber)
        Torch.Utils.updateManagedValue(&object.numbers, numbers)
        Torch.Utils.updateManagedValue(&object.text, text)
        Torch.Utils.updateManagedValue(&object.float, float)
        Torch.Utils.updateManagedValue(&object.double, double)
        Torch.Utils.updateManagedValue(&object.bool, bool)
        Torch.Utils.updateManagedValue(&object.set, set)
        Torch.Utils.updateManagedValue(&object.relation, &relation, database)
        Torch.Utils.updateManagedValue(&object.optionalRelation, &optionalRelation, database)
        Torch.Utils.updateManagedValue(&object.arrayWithRelation, &arrayWithRelation, database)
        Torch.Utils.updateManagedValue(&object.readOnly, readOnly)
    }

    internal static func torch_deleteValueTypeWrappers(object: Torch_Data, @noescape deleteFunction: (RealmSwift.Object) -> Void) {
        object.numbers.forEach { deleteFunction($0) }
    }
}

internal class Torch_Data: RealmSwift.Object, Torch.ManagedObject {
    internal dynamic var id = Int()
    internal dynamic var number = Int()
    internal var optionalNumber = RealmSwift.RealmOptional<Int>()
    internal var numbers = RealmSwift.List<Torch_Data_numbers>()
    internal dynamic var text = String()
    internal dynamic var float = Float()
    internal dynamic var double = Double()
    internal dynamic var bool = Bool()
    internal dynamic var set = Set<Int>()
    internal dynamic var relation: Torch_OtherData?
    internal dynamic var optionalRelation: Torch_OtherData?
    internal var arrayWithRelation = RealmSwift.List<Torch_OtherData>()
    internal dynamic var readOnly = String()

    internal override static func primaryKey() -> String? {
        return "id"
    }
}

internal class Torch_Data_numbers: RealmSwift.Object, Torch.ValueTypeWrapper {
    dynamic var value = Int()
}

internal extension OtherData {

    internal static let id = Torch.Property<OtherData, Int?>(name: "id")
    internal static let text = Torch.Property<OtherData, String>(name: "text")

    internal init(fromManagedObject object: Torch_OtherData) {
        id = Torch.Utils.toValue(object.id)
        text = Torch.Utils.toValue(object.text)
    }

    internal mutating func torch_updateManagedObject(object: Torch_OtherData, database: Torch.Database) {
        Torch.Utils.updateManagedValue(&object.text, text)
    }

    internal static func torch_deleteValueTypeWrappers(object: Torch_OtherData, @noescape deleteFunction: (RealmSwift.Object) -> Void) {
    }
}

internal class Torch_OtherData: RealmSwift.Object, Torch.ManagedObject {
    internal dynamic var id = Int()
    internal dynamic var text = String()

    internal override static func primaryKey() -> String? {
        return "id"
    }
}
