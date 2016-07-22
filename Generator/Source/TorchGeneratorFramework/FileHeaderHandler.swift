//
//  FileHeaderHandler.swift
//  TorchGenerator
//
//  Created by Filip Dolnik on 21.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import FileKit

public struct FileHeaderHandler {
    
    public static func getHeader(file: FileRepresentation, withTimestamp timestamp: Bool) -> String {
        let path: String
        if let absolutePath = file.sourceFile.path {
            path = getRelativePath(absolutePath)
        } else {
            path = "unknown"
        }
        let generationInfo = "// MARK: - Torch entity extensions generated from file: \(path)" + (timestamp ? " at \(NSDate())" : "")
        return generationInfo + "\n\n"
    }
    
    public static func getImports(file: FileRepresentation, libraries: [String]) -> String {
        var imports = Array(Set(libraries.map { "import " + $0 + "\n" })).sort().joinWithSeparator("")
        if imports.isEmpty == false {
            imports += "\n"
        }
        return "import Torch\n" + "import CoreData\n\n" + imports
    }

    private static func getRelativePath(absolutePath: String) -> String {
        let path = Path(absolutePath)
        let base = path.commonAncestor(Path.Current)
        let components = path.components.suffixFrom(base.components.endIndex)
        let result = components.map { $0.rawValue }.joinWithSeparator(Path.separator)
        let difference = Path.Current.components.endIndex - base.components.endIndex
        return (0..<difference).reduce(result) { acc, _ in ".." + Path.separator + acc }
    }
}
