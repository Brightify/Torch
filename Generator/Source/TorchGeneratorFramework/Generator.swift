//
//  Generator.swift
//  TorchGenerator
//
//  Created by Filip Dolnik on 21.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

public struct Generator {
    
    private let allEntities: [String]
    private let moduleName: String
    
    public init(moduleName: String, allEntities: [StructDeclaration]) {
        self.moduleName = moduleName
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
    public func generateBundle(entities: [StructDeclaration]) -> (name: String, content: String) {
        // We want the bundle to be as open as the most open entity.
        let mostOpenAccesibility = entities.map { $0.accessibility }.sort { $0.isMoreOpenThan($1) }.first ?? .Internal
        let entityTypeNames = entities.map { "\($0.name).self," }
        let bundleName = "\(moduleName)EntityBundle"
        var builder = CodeBuilder()
        builder += "\(mostOpenAccesibility.sourceName) struct \(bundleName): Torch.TorchEntityBundle {"
        builder.nest {
            $0 += "\(mostOpenAccesibility.sourceName) let entityTypes: [Torch.TorchEntity.Type] = ["
            $0.nest {
                $0.nest {
                    $0 += entityTypeNames
                    $0 += ""
                }
                $0 += "]"
            }
            $0 += ""
            $0 += "\(mostOpenAccesibility.sourceName) init() { }"
        }
        builder += "}"
        return (name: "\(bundleName).swift", content: builder.code)
    }
    
    @warn_unused_result
    private func generate(entity: StructDeclaration) -> CodeBuilder {
        var builder = CodeBuilder()
        let variables = entity.children
            .flatMap { $0 as? InstanceVariable }
            .filter { !($0.isReadOnly && allEntities.contains($0.rawType)) }

        builder += "\(entity.accessibility.sourceName) extension \(entity.name) {"
        builder.nest {
            $0 += ""
            $0 += generateName(entity)
            $0 += ""
            $0 += generateStaticProperties(entity, variables: variables)
            $0 += ""
            $0 += generateInit(entity, variables: variables)
            $0 += ""
            $0 += generateUpdateManagedObject(entity, variables: variables)
            $0 += ""
            $0 += generateDiscribeEntity(entity)
            $0 += ""
            $0 += generateDiscribeProperties(entity, variables: variables)
        }
        builder += "}"
        return builder
    }

    @warn_unused_result
    private func generateName(entity: StructDeclaration) -> CodeBuilder {
        var builder = CodeBuilder()
        builder += "\(entity.accessibility.sourceName) static var torch_name: String {"
        builder.nest("return \"\(moduleName).\(entity.name)\"")
        builder += "}"
        return builder
    }
    
    @warn_unused_result
    private func generateStaticProperties(entity: StructDeclaration, variables: [InstanceVariable]) -> CodeBuilder {
        var builder = CodeBuilder()
        for variable in variables {
            builder += "\(variable.accessibility.sourceName) static let \(variable.name) = Torch.TorchProperty<\(entity.name), \(variable.type)>(name: \"\(variable.name)\")"
        }
        return builder
    }
    
    @warn_unused_result
    private func generateInit(entity: StructDeclaration, variables: [InstanceVariable]) -> CodeBuilder {
        var builder = CodeBuilder()
        builder += "\(entity.accessibility.sourceName) init(fromManagedObject object: Torch.NSManagedObjectWrapper) throws {"
        builder.nest {
            for variable in variables {
                let tryText = isTorchEntity(variable) ? "try " : ""
                $0 += "\(variable.name) = \(tryText)object.getValue(\(entity.name).\(variable.name))"
            }
        }
        builder += "}"
        return builder
    }
    
    @warn_unused_result
    private func generateUpdateManagedObject(entity: StructDeclaration, variables: [InstanceVariable]) -> CodeBuilder {
        var builder = CodeBuilder()
        builder += "\(entity.accessibility.sourceName) mutating func torch_updateManagedObject(object: Torch.NSManagedObjectWrapper) throws {"
        builder.nest {
            for variable in variables {
                let tryText = isTorchEntity(variable) ? "try " : ""
                let referenceText = isTorchEntity(variable) ? "&" : ""
                $0 += "\(tryText)object.setValue(\(referenceText)\(variable.name), for: \(entity.name).\(variable.name))"
            }
        }
        builder += "}"
        return builder
    }
    
    @warn_unused_result
    private func generateDiscribeEntity(entity: StructDeclaration) -> CodeBuilder {
        var builder = CodeBuilder()
        builder += "\(entity.accessibility.sourceName) static func torch_describeEntity(to registry: Torch.EntityRegistry) {"
        builder.nest("registry.description(of: \(entity.name).self)")
        builder += "}"
        return builder
    }
    
    @warn_unused_result
    private func generateDiscribeProperties(entity: StructDeclaration, variables: [InstanceVariable]) -> CodeBuilder {
        var builder = CodeBuilder()
        builder += "\(entity.accessibility.sourceName) static func torch_describeProperties(to registry: Torch.PropertyRegistry) {"
        builder.nest {
            for variable in variables {
                $0 += "registry.description(of: \(entity.name).\(variable.name))"
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