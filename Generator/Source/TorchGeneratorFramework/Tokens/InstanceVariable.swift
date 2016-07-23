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
        return type.hasPrefix("[") && !type.containsString(":")
    }
    
    public var rawType: String {
        var result = type
        if isOptional {
            result.removeAtIndex(result.endIndex.advancedBy(-1))
        }
        if isArray {
            result.removeAtIndex(result.startIndex)
            result.removeAtIndex(result.endIndex.advancedBy(-1))
        }
        return result
    }

    public var isEntityToken: Bool {
        return false
    }
}