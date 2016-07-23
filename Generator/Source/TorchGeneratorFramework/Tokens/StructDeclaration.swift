//
//  StructDeclaration.swift
//  TorchGenerator
//
//  Created by Filip Dolnik on 21.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

public enum StructKind: String {
    case Plain = "*"
    case TorchEntity
    case ManualTorchEntity
}

public struct StructDeclaration: Token {
    public let name: String
    public let accessibility: Accessibility
    public let children: [Token]
    public let kind: StructKind

    public var isEntityToken: Bool {
        return kind != .Plain
    }
}