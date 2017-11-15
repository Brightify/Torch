//
//  Generator.swift
//  TorchGenerator
//
//  Created by Filip Dolnik on 21.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

public struct Generator {

    private static let ValueTypes = ["Bool", "Int8", "Int16", "Int32", "Int64", "Int", "Double", "Float", "String", "Date", "NSDate", "NSData"]
    private static let RealmOptionalTypes = ["Bool", "Int8", "Int16", "Int32", "Int64", "Int", "Double", "Float"]

    private let allEntities: [String]
    private let manualEntities: [String]

    public init(allEntities: [StructDeclaration], manualEntities: [String]) {
        self.allEntities = allEntities.map { $0.name }
        self.manualEntities = manualEntities
    }

    public func generate(_ entities: [StructDeclaration]) -> String {
        var builder = CodeBuilder()
        var first = true
        for entity in entities where entity.kind == .TorchEntity {
            if !first {
                builder += ""
            } else {
                first = false
            }
            builder += generate(entity)
        }
        return builder.code
    }

    private func generate(_ entity: StructDeclaration) -> CodeBuilder {
        var builder = CodeBuilder()
        let variables = entity.children
            .flatMap { $0 as? InstanceVariable }
            .filter { !($0.isReadOnly && allEntities.contains($0.rawType)) }

        builder += "\(entity.accessibility.sourceName) extension \(entity.name) {"
        builder.nest {
            $0 += generateStaticProperties(entity, variables: variables)
            $0 += ""
            $0 += generateInit(entity, variables: variables)
            $0 += ""
            $0 += generateUpdateManagedObject(entity, variables: variables)
            $0 += ""
            $0 += generateDeleteValueTypeWrappers(entity, variables: variables)
        }
        builder += "}"
        builder += ""
        builder += generateManagedObject(entity, variables: variables)
        let wrappers = generateWrappers(entity, variables: variables)
        if !wrappers.code.isEmpty {
            builder += ""
            builder += wrappers
        }
        return builder
    }

    private func generateStaticProperties(_ entity: StructDeclaration, variables: [InstanceVariable]) -> CodeBuilder {
        var builder = CodeBuilder()
        for variable in variables {

            let name = isId(variable) ? variable.name : getPrefixedPropertyName(variable.name)
            builder += "\(variable.accessibility.sourceName) static let \(variable.name) = Torch.Property<\(entity.name), \(variable.type)>(name: \"\(name)\")"
        }
        return builder
    }

    private func generateInit(_ entity: StructDeclaration, variables: [InstanceVariable]) -> CodeBuilder {
        var builder = CodeBuilder()
        builder += "\(entity.accessibility.sourceName) init(fromManagedObject object: \(getManagedObjectName(entity.name))) {"
        builder.nest {
            for variable in variables {
                if isValueConvertible(variable) && variable.isOptional {
                    $0 += "\(variable.name) = Torch.Utils.toValue(object.\(getPrefixedPropertyName(variable.name)), object.\(getIsNilName(variable.name)))"
                } else if isId(variable) {
                    $0 += "\(variable.name) = Torch.Utils.toValue(object.id)"
                } else {
                    $0 += "\(variable.name) = Torch.Utils.toValue(object.\(getPrefixedPropertyName(variable.name)))"
                }
            }
        }
        builder += "}"
        return builder
    }

    private func generateUpdateManagedObject(_ entity: StructDeclaration, variables: [InstanceVariable]) -> CodeBuilder {
        var builder = CodeBuilder()
        builder += "\(entity.accessibility.sourceName) mutating func torch_update(managedObject object: \(getManagedObjectName(entity.name)), database: Torch.Database) {"
        builder.nest {
            for variable in variables where !isId(variable) {
                if isTorchEntity(variable) {
                    $0 += "Torch.Utils.updateManagedValue(&object.\(getPrefixedPropertyName(variable.name)), &\(variable.name), database)"
                } else if isValueConvertible(variable) && variable.isOptional {
                    $0 += "Torch.Utils.updateManagedValue(&object.\(getPrefixedPropertyName(variable.name)), &object.\(getIsNilName(variable.name)), \(variable.name))"
                } else {
                    $0 += "Torch.Utils.updateManagedValue(&object.\(getPrefixedPropertyName(variable.name)), \(variable.name))"
                }
            }
        }
        builder += "}"
        return builder
    }

    private func generateDeleteValueTypeWrappers(_ entity: StructDeclaration, variables: [InstanceVariable]) -> CodeBuilder {
        var builder = CodeBuilder()
        builder += "\(entity.accessibility.sourceName) static func torch_delete(managedObject object: \(getManagedObjectName(entity.name))" +
                    ", deleteFunction: (RealmSwift.Object) -> Void) {"
        builder.nest {
            for variable in variables where isArrayWithValues(variable) {
                $0 += "object.\(getPrefixedPropertyName(variable.name)).forEach { deleteFunction($0) }"
            }
        }
        builder += "}"
        return builder
    }

    private func generateManagedObject(_ entity: StructDeclaration, variables: [InstanceVariable]) -> CodeBuilder {
        var builder = CodeBuilder()
        let accessibility = entity.accessibility.sourceName
        builder += "\(accessibility) class \(getManagedObjectName(entity.name)): RealmSwift.Object, Torch.ManagedObject {"
        builder.nest {
            for variable in variables {
                if isValueConvertible(variable) {
                    if variable.isArray {
                        $0 += "\(accessibility) var \(getPrefixedPropertyName(variable.name)) = RealmSwift.List<\(getWrapperName(entity.name, variable.name))>()"
                    } else {
                        $0 += "@objc \(accessibility) dynamic var \(getPrefixedPropertyName(variable.name)) = \(variable.rawType).getDefaultValue().toValue()"
                    }
                    if variable.isOptional {
                        $0 += "@objc \(accessibility) dynamic var \(getIsNilName(variable.name)) = true"
                    }
                } else {
                    if isId(variable) {
                        $0 += "@objc \(accessibility) dynamic var id = Int()"
                    } else if isArrayWithValues(variable) {
                        $0 += "\(accessibility) var \(getPrefixedPropertyName(variable.name)) = RealmSwift.List<\(getWrapperName(entity.name, variable.name))>()"
                    } else if variable.isArray {
                        $0 += "\(accessibility) var \(getPrefixedPropertyName(variable.name)) = RealmSwift.List<\(getManagedObjectType(variable.rawType))>()"
                    } else if isRealmOptional(variable) {
                        $0 += "\(accessibility) var \(getPrefixedPropertyName(variable.name)) = RealmSwift.RealmOptional<\(variable.rawType)>()"
                    } else if isTorchEntity(variable) {
                        $0 += "@objc \(accessibility) dynamic var \(getPrefixedPropertyName(variable.name)): \(getManagedObjectType(variable.rawType))?"
                    } else if variable.isOptional {
                        $0 += "@objc \(accessibility) dynamic var \(getPrefixedPropertyName(variable.name)): \(variable.type)"
                    } else {
                        $0 += "@objc \(accessibility) dynamic var \(getPrefixedPropertyName(variable.name)) = \(variable.type)()"
                    }
                }
            }

            $0 += ""
            $0 += "\(accessibility) override static func primaryKey() -> String? {"
            $0.nest("return \"id\"")
            $0 += "}"
        }
        builder += "}"
        return builder
    }

    private func generateWrappers(_ entity: StructDeclaration, variables: [InstanceVariable]) -> CodeBuilder {
        var builder = CodeBuilder()
        var first = true
        for variable in variables where isArrayWithValues(variable) || (isValueConvertible(variable) && variable.isArray) {
            if !first {
                builder += ""
            } else {
                first = false
            }
            builder += "\(entity.accessibility.sourceName) class \(getWrapperName(entity.name, variable.name)): RealmSwift.Object, Torch.ValueTypeWrapper {"
            if isValueConvertible(variable) {
                builder.nest("@objc dynamic var value = \(variable.rawType).getDefaultValue().toValue()")
            } else {
                 builder.nest("@objc dynamic var value = \(variable.rawType)()")
            }
            builder += "}"
        }
        return builder
    }

    private func isTorchEntity(_ variable: InstanceVariable) -> Bool {
        return allEntities.contains(variable.rawType) || manualEntities.contains(variable.rawType)
    }

    private func isId(_ variable: InstanceVariable) -> Bool {
        return variable.name == "id"
    }

    private func isArrayWithValues(_ variable: InstanceVariable) -> Bool {
        return variable.isArray && !isTorchEntity(variable)
    }

    private func isRealmOptional(_ variable: InstanceVariable) -> Bool {
        return variable.isOptional && Generator.RealmOptionalTypes.contains(variable.rawType)
    }

    private func isValueConvertible(_ variable: InstanceVariable) -> Bool {
        return !Generator.ValueTypes.contains(variable.rawType) && !isTorchEntity(variable)
    }

    private func getManagedObjectName(_ entityName: String) -> String {
        return "Torch_" + entityName
    }

    private func getManagedObjectType(_ entityName: String) -> String {
        return entityName + ".ManagedObjectType"
    }

    private func getWrapperName(_ entityName: String, _ variableName: String) -> String {
        return getManagedObjectName(entityName) + "_" + variableName
    }

    private func getIsNilName(_ variableName: String) -> String {
        return getPrefixedPropertyName(variableName) + "_isNil"
    }

    private func getPrefixedPropertyName(_ variableName: String) -> String {
        return "torch_\(variableName)"
    }
}
