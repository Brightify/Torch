//
//  FileHeaderHandler.swift
//  TorchGenerator
//
//  Created by Filip Dolnik on 21.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import FileKit
import Foundation

public struct FileHeaderHandler {

    public static func getHeader(_ file: FileRepresentation, withTimestamp timestamp: Bool) -> String {
        let path: String
        if let absolutePath = file.sourceFile.path {
            path = getRelativePath(absolutePath)
        } else {
            path = "unknown"
        }
        let generationInfo = "// MARK: - Torch entity extensions generated from file: \(path)" + (timestamp ? " at \(Date())" : "")
        return generationInfo + "\n\n"
    }

    public static func getImports(_ file: FileRepresentation, libraries: [String]) -> String {
        var imports = Array(Set(libraries.map { "import " + $0 + "\n" })).sorted().joined(separator: "")
        if imports.isEmpty == false {
            imports += "\n"
        }
        return "import Torch\n" + "import RealmSwift\n\n" + imports
    }

    fileprivate static func getRelativePath(_ absolutePath: String) -> String {
        let path = Path(absolutePath)
        let base = path.commonAncestor(Path.current)
        let components = path.components.suffix(from: base.components.endIndex)
        let result = components.map { $0.rawValue }.joined(separator: Path.separator)
        let difference = Path.current.components.endIndex - base.components.endIndex
        return (0..<difference).reduce(result) { acc, _ in ".." + Path.separator + acc }
    }
}
