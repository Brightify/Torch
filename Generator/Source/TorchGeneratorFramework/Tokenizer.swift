//
//  Tokenizer.swift
//  TorchGenerator
//
//  Created by Filip Dolnik on 21.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import SourceKittenFramework

public struct Tokenizer {
    fileprivate let file: File
    fileprivate let source: String

    public init(sourceFile: File) {
        self.file = sourceFile
        
        source = sourceFile.contents
    }
    
    public func tokenize() -> FileRepresentation {
        let structure = Structure(file: file)
        
        let declarations = tokenize(structure.dictionary[Key.Substructure.rawValue] as? [SourceKitRepresentable] ?? [])
        
        return FileRepresentation(sourceFile: file, declarations: declarations)
    }
    
    fileprivate func tokenize(_ representables: [SourceKitRepresentable]) -> [Token] {
        return representables.flatMap(tokenize)
    }
    
    fileprivate func tokenize(_ representable: SourceKitRepresentable) -> Token? {
        guard let dictionary = representable as? [String: SourceKitRepresentable] else { return nil }
        
        let name = dictionary[Key.Name.rawValue] as? String ?? "name not set"
        let kind = dictionary[Key.Kind.rawValue] as? String ?? "unknown type"
        let accesibility = (dictionary[Key.Accessibility.rawValue] as? String).flatMap { Accessibility(rawValue: $0) }
        
        switch kind {
        case Kinds.StructDeclaration.rawValue, Kinds.EnumDeclaration.rawValue:
            if accesibility == .Private {
                return nil
            }
            
            let children = tokenize(dictionary[Key.Substructure.rawValue] as? [SourceKitRepresentable] ?? [])
            
            let inheritedTypes = dictionary[Key.InheritedTypes.rawValue] as? [SourceKitRepresentable] ?? []
            let inheritedTypeNames = inheritedTypes.flatMap { $0 as? [String: SourceKitRepresentable] }.flatMap { $0[Key.Name.rawValue] as? String }
            let structKind: StructKind
            if inheritedTypeNames.contains(StructKind.TorchEntity.rawValue) {
                structKind = .TorchEntity
            } else if inheritedTypeNames.contains(StructKind.ManualTorchEntity.rawValue) {
                structKind = .ManualTorchEntity
            } else {
                structKind = .Plain
            }
            
            return StructDeclaration(
                name: name,
                accessibility: accesibility!,
                children: children,
                kind: structKind
            )
        case Kinds.InstanceVariable.rawValue:
            return InstanceVariable(
                name: name,
                type: dictionary[Key.TypeName.rawValue] as! String,
                accessibility: accesibility!,
                isReadOnly: dictionary[Key.SetterAccessibility.rawValue] as? String == nil
            )
        default:
            return nil
        }
    }
}
