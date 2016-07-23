//
//  GenerateMocksCommand.swift
//  TorchGenerator
//
//  Created by Filip Dolnik on 21.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Commandant
import Result
import SourceKittenFramework
import FileKit
import TorchGeneratorFramework

public struct GenerateMocksCommand: CommandType {
    
    public let verb = "generate"
    public let function = "Generates files with TorchEntities extensions"
    
    public func run(options: Options) -> Result<Void, TorchGeneratorError> {
        let inputFiles = getInputFiles(Path(options.source))
        let parsedFiles = inputFiles.map { Tokenizer(sourceFile: $0).tokenize() }.filter { $0.containsTorchEntity }
        let filesContent = generateFilesContent(parsedFiles, options: options)
        let files = zip(parsedFiles.map { $0.sourceFile }, filesContent).map { (name: options.filePrefix + Path($0.path ?? "Unknown").fileName, content: $1) }
        return writeData(files, outputPath: Path(options.output))
    }
    
    private func getInputFiles(path: Path) -> [SourceKittenFramework.File] {
        if path.isDirectory {
            return path.find { $0.pathExtension == "swift"}.map { File(path: $0.standardRawValue) }.flatMap { $0 }
        } else {
            return [File(path: path.standardRawValue)].flatMap { $0 }
        }
    }
    
    private func generateFilesContent(parsedFiles: [FileRepresentation], options: Options) -> [String] {
        var allEntities: [StructDeclaration] = []
        func registerEntities(tokens: [Token], inout to array: [StructDeclaration]) {
            tokens.flatMap { $0 as? StructDeclaration }.filter { $0.isEntityToken }.forEach {
                array.append($0)
                // Look for nested entities
                registerEntities($0.children, to: &array)
            }
        }
        registerEntities(parsedFiles.flatMap { $0.declarations }, to: &allEntities)
        let generator = Generator(entityNamePrefix: options.entityNamePrefix, allEntities: allEntities)
        
        let headers = parsedFiles.map { options.noHeader ? "" : FileHeaderHandler.getHeader($0, withTimestamp: !options.noTimestamp) }
        let imports = parsedFiles.map { FileHeaderHandler.getImports($0, libraries: options.libraries) }
        let extensions: [String] = parsedFiles.map {
            var entitiesInFile: [StructDeclaration] = []
            registerEntities($0.declarations, to: &entitiesInFile)
            return generator.generate(entitiesInFile)
        }
        return zip(zip(headers, imports), extensions).map { $0.0 + $0.1 + $1 }
    }
    
    private func writeData(files: [(name: String, content: String)], outputPath: Path) -> Result<Void, TorchGeneratorError> {
        do {
            if outputPath.isDirectory {
                for (name, content) in files {
                    let outputFile = TextFile(path: outputPath + name)
                    try content |> outputFile
                }
            } else {
                let outputFile = TextFile(path: outputPath)
                try files.map { $0.content }.joinWithSeparator("\n") |> outputFile
            }
        } catch let error as FileKitError {
            return .Failure(.IOError(error))
        } catch let error {
            return .Failure(.UnknownError(error))
        }
        return .Success()
    }
    
    public struct Options: OptionsType {
        let source: String
        let output: String
        let noHeader: Bool
        let noTimestamp: Bool
        let libraries: [String]
        let filePrefix: String
        let entityNamePrefix: String
        
        public static func create(output: String)(noHeader: Bool)(noTimestamp: Bool)(libraries: String)(filePrefix: String)(entityNamePrefix: String)(source: String) -> Options {
            return Options(source: source, output: output, noHeader: noHeader, noTimestamp: noTimestamp, libraries: libraries.componentsSeparatedByString(",").filter { !$0.isEmpty }, filePrefix: filePrefix, entityNamePrefix: entityNamePrefix)
        }
        
        public static func evaluate(m: CommandMode) -> Result<Options, CommandantError<TorchGeneratorError>> {
            return create
                <*> m <| Option(key: "output", defaultValue: "GeneratedTorchEntityExtensions.swift", usage: "Where to put the generated extensions.\nIf a path to a directory is supplied, each input file will have a respective output file with extension.\nIf a path to a Swift file is supplied, all extensions will be in a single file.\nDefault value is `GeneratedTorchEntityExtensions.swift`.")
                <*> m <| Option(key: "no-header", defaultValue: false, usage: "Do not generate file headers.")
                <*> m <| Option(key: "no-timestamp", defaultValue: false, usage: "Do not generate timestamp.")
                <*> m <| Option(key: "libraries", defaultValue: "", usage: "A comma separated list of libraries that should be imported in the generated file(s).")
                <*> m <| Option(key: "file-prefix", defaultValue: "", usage: "Names of generated files in directory will start with this prefix. Only works when output path is directory.")
                <*> m <| Option(key: "entity-name-prefix", defaultValue: "TorchEntity", usage: "Represents prefix for generated entity names. Should be equal to project name. Default value is `TorchEntity`.")
                <*> m <| Argument(usage: "Directory/File path where to look for TorchEntities. If supplied path represents directory then the search will be recursive. Search will be done only in files with .swift extension.")
        }
    }
}