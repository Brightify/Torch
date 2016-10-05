//
//  InstanceVariable.swift
//  TorchGenerator
//
//  Created by Filip Dolnik on 21.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

public struct InstanceVariable: Token {
    public let name: String
    public let type: String
    public let accessibility: Accessibility
    public let isReadOnly: Bool
    
    public var isOptional: Bool {
        return type.hasSuffix("?")
    }
    
    public var isArray: Bool {
        return type.hasPrefix("[") && !type.contains(":")
    }
    
    public var rawType: String {
        var result = type
        if isOptional {
            result.remove(at: result.characters.index(result.endIndex, offsetBy: -1))
        }
        if isArray {
            result.remove(at: result.startIndex)
            result.remove(at: result.characters.index(result.endIndex, offsetBy: -1))
        }
        return result
    }

    public var isEntityToken: Bool {
        return false
    }
}
