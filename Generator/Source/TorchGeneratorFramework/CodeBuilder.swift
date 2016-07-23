//
//  CodeBuilder.swift
//  TorchGenerator
//
//  Created by Filip Dolnik on 21.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

public struct CodeBuilder {
    private static let tab = "    "

    public private(set) var code = ""
    
    private var nesting = 0

    private var nest: String {
        return (0 ..< nesting).reduce("") { acc, _ in acc + CodeBuilder.tab }
    }
    
    public mutating func clear() {
        code = ""
    }
    
    public mutating func nest(@noescape closure: () -> ()) {
        nesting += 1
        closure()
        nesting -= 1
    }
    
    public mutating func nest(line: String) {
        nest { self += line }
    }

    public mutating func append(line line: String) {
        code += "\(nest)\(line)\n"
    }

    public mutating func append(lines lines: [String]) {
        lines.forEach { append(line: $0) }
    }

    public mutating func append(builder subbuilder: CodeBuilder) {
        let lines = subbuilder.code.characters
            .split(allowEmptySlices: true) { $0 == "\n" || $0 == "\r\n" }
            .map(String.init)
        append(lines: lines)
    }
}



public func +=(inout builder: CodeBuilder, string: String) {
    builder.append(line: string)
}

public func +=(inout builder: CodeBuilder, subbuilder: CodeBuilder) {
    builder.append(builder: subbuilder)
}