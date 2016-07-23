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
    
    public mutating func nest(@noescape closure: (inout builder: CodeBuilder) -> ()) {
        nesting += 1
        closure(builder: &self)
        nesting -= 1
    }
    
    public mutating func nest(line: String) {
        nest { $0 += line }
    }

    public mutating func append(line line: String, insertLineBreak: Bool = true) {
        if line == "" {
            code += insertLineBreak ? "\n" : ""
        } else {
            code += "\(nest)\(line)\(insertLineBreak ? "\n" : "")"
        }
    }

    public mutating func append(lines lines: [String]) {
        lines.enumerate().forEach {
            if $0 > 0 {
                append(line: "")
            }
            append(line: $1, insertLineBreak: false)
        }
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

public func +=(inout builder: CodeBuilder, lines: [String]) {
    builder.append(lines: lines)
}

public func +=(inout builder: CodeBuilder, subbuilder: CodeBuilder) {
    builder.append(builder: subbuilder)
}