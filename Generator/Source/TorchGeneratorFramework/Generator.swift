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
    private let code = CodeBuilder()
    
    public init(entityNamePrefix: String, allEntities: [StructDeclaration]) {
        self.entityNamePrefix = entityNamePrefix
        self.allEntities = allEntities.map { $0.name }
    }
    
    public func generate(entities: [StructDeclaration]) -> String {
        code.clear()
        for (i, entity) in entities.enumerate() {
            generate(entity)
            if i + 1 != entities.count {
                code += ""
            }
        }
        return code.code
    }
    
    private func generate(entity: StructDeclaration) {
        let variables = entity.children.flatMap { $0 as? InstanceVariable }.filter { !($0.isReadOnly && allEntities.contains($0.rawType)) }
        code += "\(entity.accessibility.sourceName)extension \(entity.name) {"
        code.nest {
            code += ""
            generateName(entity)
            code += ""
            generateStaticProperties(entity, variables: variables)
            code += ""
            generateInit(entity, variables: variables)
            code += ""
            generateUpdateManagedObject(entity, variables: variables)
            code += ""
            generateDiscribeEntity(entity)
            code += ""
            generateDiscribeProperties(entity, variables: variables)
        }
        code += "}"
    }
    
    private func generateName(entity: StructDeclaration) {
        code += "\(entity.accessibility.sourceName)static var torch_name: String {"
        code.nest("return \"\(entityNamePrefix).\(entity.name)\"")
        code += "}"
    }
    
    private func generateStaticProperties(entity: StructDeclaration, variables: [InstanceVariable]) {
        for variable in variables {
            code += "\(variable.accessibility.sourceName)static let \(variable.name) = Torch.TorchProperty<\(entity.name), \(variable.type)>(name: \"\(variable.name)\")"
        }
    }
    
    private func generateInit(entity: StructDeclaration, variables: [InstanceVariable]) {
        code += "\(entity.accessibility.sourceName)init(fromManagedObject object: Torch.NSManagedObjectWrapper) throws {"
        code.nest {
            for variable in variables {
                let tryText = isTorchEntity(variable) ? "try " : ""
                code += "\(variable.name) = \(tryText)object.getValue(\(entity.name).\(variable.name))"
            }
        }
        code += "}"
    }
    
    private func generateUpdateManagedObject(entity: StructDeclaration, variables: [InstanceVariable]) {
        code += "\(entity.accessibility.sourceName)mutating func torch_updateManagedObject(object: Torch.NSManagedObjectWrapper) throws {"
        code.nest {
            for variable in variables {
                let tryText = isTorchEntity(variable) ? "try " : ""
                let referenceText = isTorchEntity(variable) ? "&" : ""
                code += "\(tryText)object.setValue(\(referenceText)\(variable.name), for: \(entity.name).\(variable.name))"
            }
        }
        code += "}"
    }
    
    private func generateDiscribeEntity(entity: StructDeclaration) {
        code += "\(entity.accessibility.sourceName)static func torch_describeEntity(to registry: Torch.EntityRegistry) {"
        code.nest("registry.description(of: \(entity.name).self)")
        code += "}"
    }
    
    private func generateDiscribeProperties(entity: StructDeclaration, variables: [InstanceVariable]) {
        code += "\(entity.accessibility.sourceName)static func torch_describeProperties(to registry: Torch.PropertyRegistry) {"
        code.nest {
            for variable in variables {
                code += "registry.description(of: \(entity.name).\(variable.name))"
            }
        }
        code += "}"
    }
    
    private func isTorchEntity(variable: InstanceVariable) -> Bool {
        return allEntities.contains(variable.rawType)
    }
}