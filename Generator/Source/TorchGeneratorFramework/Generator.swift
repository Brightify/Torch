//
//  Generator.swift
//  TorchGenerator
//
//  Created by Filip Dolnik on 21.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

public struct Generator {
    
    private let allEntities: [String]
    private let entityNamePrefix: String
    
    public init(entityNamePrefix: String, allEntities: [StructDeclaration]) {
        self.entityNamePrefix = entityNamePrefix
        self.allEntities = allEntities.map { $0.name }
    }
    
    @warn_unused_result
    public func generate(entities: [StructDeclaration]) -> String {
        var builder = CodeBuilder()
        for (i, entity) in entities.enumerate() where entity.kind == .TorchEntity {
            builder += generate(entity)
            if i + 1 != entities.count {
                builder += ""
            }
        }
        return builder.code
    }
    
    @warn_unused_result
    private func generate(entity: StructDeclaration) -> CodeBuilder {
        var builder = CodeBuilder()
        let variables = entity.children
            .flatMap { $0 as? InstanceVariable }
            .filter { !($0.isReadOnly && allEntities.contains($0.rawType)) }

        builder += "\(entity.accessibility.sourceName)extension \(entity.name) {"
        builder.nest {
            builder += ""
            builder += generateName(entity)
            builder += ""
            builder += generateStaticProperties(entity, variables: variables)
            builder += ""
            builder += generateInit(entity, variables: variables)
            builder += ""
            builder += generateUpdateManagedObject(entity, variables: variables)
            builder += ""
            builder += generateDiscribeEntity(entity)
            builder += ""
            builder += generateDiscribeProperties(entity, variables: variables)
        }
        builder += "}"
        return builder
    }

    @warn_unused_result
    private func generateName(entity: StructDeclaration) -> CodeBuilder {
        var builder = CodeBuilder()
        builder += "\(entity.accessibility.sourceName)static var torch_name: String {"
        builder.nest("return \"\(entityNamePrefix).\(entity.name)\"")
        builder += "}"
        return builder
    }
    
    @warn_unused_result
    private func generateStaticProperties(entity: StructDeclaration, variables: [InstanceVariable]) -> CodeBuilder {
        var builder = CodeBuilder()
        for variable in variables {
            builder += "\(variable.accessibility.sourceName)static let \(variable.name) = Torch.TorchProperty<\(entity.name), \(variable.type)>(name: \"\(variable.name)\")"
        }
        return builder
    }
    
    @warn_unused_result
    private func generateInit(entity: StructDeclaration, variables: [InstanceVariable]) -> CodeBuilder {
        var builder = CodeBuilder()
        builder += "\(entity.accessibility.sourceName)init(fromManagedObject object: Torch.NSManagedObjectWrapper) throws {"
        builder.nest {
            for variable in variables {
                let tryText = isTorchEntity(variable) ? "try " : ""
                builder += "\(variable.name) = \(tryText)object.getValue(\(entity.name).\(variable.name))"
            }
        }
        builder += "}"
        return builder
    }
    
    @warn_unused_result
    private func generateUpdateManagedObject(entity: StructDeclaration, variables: [InstanceVariable]) -> CodeBuilder {
        var builder = CodeBuilder()
        builder += "\(entity.accessibility.sourceName)mutating func torch_updateManagedObject(object: Torch.NSManagedObjectWrapper) throws {"
        builder.nest {
            for variable in variables {
                let tryText = isTorchEntity(variable) ? "try " : ""
                let referenceText = isTorchEntity(variable) ? "&" : ""
                builder += "\(tryText)object.setValue(\(referenceText)\(variable.name), for: \(entity.name).\(variable.name))"
            }
        }
        builder += "}"
        return builder
    }
    
    @warn_unused_result
    private func generateDiscribeEntity(entity: StructDeclaration) -> CodeBuilder {
        var builder = CodeBuilder()
        builder += "\(entity.accessibility.sourceName)static func torch_describeEntity(to registry: Torch.EntityRegistry) {"
        builder.nest("registry.description(of: \(entity.name).self)")
        builder += "}"
        return builder
    }
    
    @warn_unused_result
    private func generateDiscribeProperties(entity: StructDeclaration, variables: [InstanceVariable]) -> CodeBuilder {
        var builder = CodeBuilder()
        builder += "\(entity.accessibility.sourceName)static func torch_describeProperties(to registry: Torch.PropertyRegistry) {"
        builder.nest {
            for variable in variables {
                builder += "registry.description(of: \(entity.name).\(variable.name))"
            }
        }
        builder += "}"
        return builder
    }
    
    @warn_unused_result
    private func isTorchEntity(variable: InstanceVariable) -> Bool {
        return allEntities.contains(variable.rawType)
    }
}