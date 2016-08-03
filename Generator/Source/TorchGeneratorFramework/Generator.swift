//
//  Generator.swift
//  TorchGenerator
//
//  Created by Filip Dolnik on 21.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

public struct Generator {
    
    private static let ValueTypes = ["Bool", "Int8", "Int16", "Int32", "Int64", "Int", "Double", "Float", "String", "NSDate", "NSData"]
    private static let RealmOptionalTypes = ["Bool", "Int8", "Int16", "Int32", "Int64", "Int", "Double", "Float"]
    
    private let allEntities: [String]
    
    public init(allEntities: [StructDeclaration]) {
        self.allEntities = allEntities.map { $0.name }
    }
    
    @warn_unused_result
    public func generate(entities: [StructDeclaration]) -> String {
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
    
    @warn_unused_result
    private func generate(entity: StructDeclaration) -> CodeBuilder {
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
    
    @warn_unused_result
    private func generateStaticProperties(entity: StructDeclaration, variables: [InstanceVariable]) -> CodeBuilder {
        var builder = CodeBuilder()
        for variable in variables {
            builder += "\(variable.accessibility.sourceName) static let \(variable.name) = Torch.Property<\(entity.name), \(variable.type)>(name: \"\(variable.name)\")"
        }
        return builder
    }
    
    @warn_unused_result
    private func generateInit(entity: StructDeclaration, variables: [InstanceVariable]) -> CodeBuilder {
        var builder = CodeBuilder()
        builder += "\(entity.accessibility.sourceName) init(fromManagedObject object: \(getManagedObjectName(entity.name))) {"
        builder.nest {
            for variable in variables {
                $0 += "\(variable.name) = Torch.Utils.toValue(object.\(variable.name))"
            }
        }
        builder += "}"
        return builder
    }
    
    @warn_unused_result
    private func generateUpdateManagedObject(entity: StructDeclaration, variables: [InstanceVariable]) -> CodeBuilder {
        var builder = CodeBuilder()
        builder += "\(entity.accessibility.sourceName) mutating func torch_updateManagedObject(object: \(getManagedObjectName(entity.name)), database: Torch.Database) {"
        builder.nest {
            for variable in variables where !isId(variable) {
                if isTorchEntity(variable) {
                    $0 += "Torch.Utils.updateManagedValue(&object.\(variable.name), &\(variable.name), database)"
                } else {
                    $0 += "Torch.Utils.updateManagedValue(&object.\(variable.name), \(variable.name))"
                }
            }
        }
        builder += "}"
        return builder
    }
    
    @warn_unused_result
    private func generateDeleteValueTypeWrappers(entity: StructDeclaration, variables: [InstanceVariable]) -> CodeBuilder {
        var builder = CodeBuilder()
        builder += "\(entity.accessibility.sourceName) static func torch_deleteValueTypeWrappers(object: \(getManagedObjectName(entity.name))" +
                    ", @noescape deleteFunction: (RealmSwift.Object) -> Void) {"
        builder.nest {
            for variable in variables where isArrayWithValues(variable) {
                $0 += "object.\(variable.name).forEach { deleteFunction($0) }"
            }
        }
        builder += "}"
        return builder
    }
    
    @warn_unused_result
    private func generateManagedObject(entity: StructDeclaration, variables: [InstanceVariable]) -> CodeBuilder {
        var builder = CodeBuilder()
        let accessibility = entity.accessibility.sourceName
        builder += "\(accessibility) class \(getManagedObjectName(entity.name)): RealmSwift.Object, Torch.ManagedObject {"
        builder.nest {
            for variable in variables {
                if isValueConvertible(variable) {
                    if variable.isArray {
                        $0 += "\(accessibility) var \(variable.name) = RealmSwift.List<\(getWrapperName(entity.name, variable.name))>()"
                    } else {
                        $0 += "\(accessibility) dynamic var \(variable.name) = \(variable.type).defaultValue.toValue()"
                    }
                } else {
                    if isId(variable) {
                        $0 += "\(accessibility) dynamic var id = Int()"
                    } else if isArrayWithValues(variable) {
                        $0 += "\(accessibility) var \(variable.name) = RealmSwift.List<\(getWrapperName(entity.name, variable.name))>()"
                    } else if variable.isArray {
                        $0 += "\(accessibility) var \(variable.name) = RealmSwift.List<\(getManagedObjectName(variable.rawType))>()"
                    } else if isRealmOptional(variable) {
                        $0 += "\(accessibility) var \(variable.name) = RealmSwift.RealmOptional<\(variable.rawType)>()"
                    } else if isTorchEntity(variable) {
                        $0 += "\(accessibility) dynamic var \(variable.name): \(getManagedObjectName(variable.rawType))?"
                    } else if variable.isOptional {
                        $0 += "\(accessibility) dynamic var \(variable.name): \(variable.type)"
                    } else {
                        $0 += "\(accessibility) dynamic var \(variable.name) = \(variable.type)()"
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
    
    @warn_unused_result
    private func generateWrappers(entity: StructDeclaration, variables: [InstanceVariable]) -> CodeBuilder {
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
                builder.nest("dynamic var value = \(variable.rawType).defaultValue.toValue()")
            } else {
                 builder.nest("dynamic var value = \(variable.rawType)()")
            }
            builder += "}"
        }
        return builder
    }
    
    @warn_unused_result
    private func isTorchEntity(variable: InstanceVariable) -> Bool {
        return allEntities.contains(variable.rawType)
    }
    
    @warn_unused_result
    private func isId(variable: InstanceVariable) -> Bool {
        return variable.name == "id"
    }
    
    @warn_unused_result
    private func isArrayWithValues(variable: InstanceVariable) -> Bool {
        return variable.isArray && !isTorchEntity(variable)
    }
    
    @warn_unused_result
    private func isRealmOptional(variable: InstanceVariable) -> Bool {
        return variable.isOptional && Generator.RealmOptionalTypes.contains(variable.rawType)
    }
    
    @warn_unused_result
    private func isValueConvertible(variable: InstanceVariable) -> Bool {
        return !Generator.ValueTypes.contains(variable.rawType) && !isTorchEntity(variable)
    }
    
    @warn_unused_result
    private func getManagedObjectName(entityName: String) -> String {
        return "Torch_" + entityName
    }
    
    @warn_unused_result
    private func getWrapperName(entityName: String, _ variableName: String) -> String {
        return getManagedObjectName(entityName) + "_" + variableName
    }
}