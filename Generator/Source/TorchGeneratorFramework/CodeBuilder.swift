//
//  CodeBuilder.swift
//  TorchGenerator
//
//  Created by Filip Dolnik on 21.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

public struct CodeBuilder {
    fileprivate static let tab = "    "

    public fileprivate(set) var code = ""

    fileprivate var nesting = 0

    fileprivate var nest: String {
        return (0 ..< nesting).reduce("") { acc, _ in acc + CodeBuilder.tab }
    }
    
    public mutating func clear() {
        code = ""
    }
    
    public mutating func nest(_ closure: (_ builder: inout CodeBuilder) -> ()) {
        nesting += 1
        closure(&self)
        nesting -= 1
    }
    
    public mutating func nest(_ line: String) {
        nest { (builder: inout CodeBuilder) in
            builder += line
        }
    }

    public mutating func append(line: String, insertLineBreak: Bool = true) {
        if line == "" {
            code += insertLineBreak ? "\n" : ""
        } else {
            code += "\(nest)\(line)\(insertLineBreak ? "\n" : "")"
        }
    }

    public mutating func append(lines: [String]) {
        lines.enumerated().forEach {
            if $0 > 0 {
                append(line: "")
            }
            append(line: $1, insertLineBreak: false)
        }
    }

    public mutating func append(builder subbuilder: CodeBuilder) {
        let lines = subbuilder.code.characters
            .split(omittingEmptySubsequences: false) { $0 == "\n" || $0 == "\r\n" }
            .map(String.init)
        append(lines: lines)
    }
}

public func +=(builder: inout CodeBuilder, string: String) {
    builder.append(line: string)
}

public func +=(builder: inout CodeBuilder, lines: [String]) {
    builder.append(lines: lines)
}

public func +=(builder: inout CodeBuilder, subbuilder: CodeBuilder) {
    builder.append(builder: subbuilder)
}
