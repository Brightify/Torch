//
//  GenerateCommand.swift
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
import Foundation

private func curry<P1, P2, P3, P4, P5, P6, P7, R>(_ f: @escaping (P1, P2, P3, P4, P5, P6, P7) -> R)
    -> (P1) -> (P2) -> (P3) -> (P4) -> (P5) -> (P6) -> (P7) -> R {
        return { p1 in { p2 in { p3 in { p4 in { p5 in { p6 in { p7 in f(p1, p2, p3, p4, p5, p6, p7) } } } } } } }
}

private func recursivelyExtractEntities(fromTokens tokens: [Token]) -> [StructDeclaration] {
    return tokens.flatMap { $0 as? StructDeclaration }.filter { $0.isEntityToken }.flatMap {
        [$0] + recursivelyExtractEntities(fromTokens: $0.children)
    }
}

public struct GenerateCommand: CommandProtocol {

    public let verb = "generate"
    public let function = "Generates files with TorchEntities extensions"

    public func run(_ options: Options) -> Result<Void, TorchGeneratorError> {
        let inputPath = Path(options.source)
        let outputPath = Path(options.output)
        let inputFiles = getInputFiles(inputPath)
        let parsedFiles = inputFiles.map { Tokenizer(sourceFile: $0).tokenize() }.filter { $0.containsTorchEntity }
        let allEntities = recursivelyExtractEntities(fromTokens: parsedFiles.flatMap { $0.declarations })
        let generator = Generator(allEntities: allEntities)
        let filesContent = generateFilesContent(parsedFiles, generator: generator, options: options)

        let files = zip(parsedFiles.map(resultFileName(options)), filesContent).map { (name: $0, content: $1) }
        return writeData(files, outputPath: outputPath)
    }

    fileprivate func resultFileName(_ options: Options) -> (_ file: FileRepresentation) -> String {
        return { file in
            let path = self.appendPrefixAndSuffix(file.sourceFile.path ?? "Unknown", options: options)
            return Path(path).fileName
        }
    }

    fileprivate func appendPrefixAndSuffix(_ path: String, options: Options) -> String {
        let nsstringPath = path as NSString
        let fileName = Path(nsstringPath.deletingPathExtension).fileName
        let fileExtension = "." + nsstringPath.pathExtension
        return options.filePrefix + fileName + options.fileSuffix + fileExtension
    }

    fileprivate func getInputFiles(_ path: Path) -> [SourceKittenFramework.File] {
        if path.isDirectory {
            return path.find { $0.pathExtension == "swift"}.map { File(path: $0.standardRawValue) }.flatMap { $0 }
        } else {
            return [File(path: path.standardRawValue)].flatMap { $0 }
        }
    }

    fileprivate func generateFilesContent(_ parsedFiles: [FileRepresentation], generator: Generator, options: Options) -> [String] {
        let headers = parsedFiles.map { options.noHeader ? "" : FileHeaderHandler.getHeader($0, withTimestamp: !options.noTimestamp) }
        let imports = parsedFiles.map { FileHeaderHandler.getImports($0, libraries: options.libraries) }
        let extensions: [String] = parsedFiles.map {
            let entitiesInFile = recursivelyExtractEntities(fromTokens: $0.declarations)
            return generator.generate(entitiesInFile)
        }

        return zip(zip(headers, imports), extensions).map { "\($0.0)\($0.1)\($1)" }
    }

    fileprivate func writeData(_ files: [(name: String, content: String)], outputPath: Path) -> Result<Void, TorchGeneratorError> {
        do {
            if outputPath.isDirectory {
                for (name, content) in files {
                    let outputFile = TextFile(path: outputPath + name)
                    try content |> outputFile
                }
            } else {
                let outputFile = TextFile(path: outputPath)
                try files.map { $0.content }.joined(separator: "\n") |> outputFile
            }
        } catch let error as FileKitError {
            return .failure(.ioError(error))
        } catch let error {
            return .failure(.unknownError(error))
        }
        return .success(())
    }

    public struct Options: OptionsProtocol {
        let output: String
        let noHeader: Bool
        let noTimestamp: Bool
        let libraries: [String]
        let filePrefix: String
        let fileSuffix: String
        let source: String

        public init(output: String,
                    noHeader: Bool,
                    noTimestamp: Bool,
                    libraries: String,
                    filePrefix: String,
                    fileSuffix: String,
                    source: String) {

            self.output = output
            self.noHeader = noHeader
            self.noTimestamp = noTimestamp
            self.libraries = libraries.characters.split { $0 == "," }.map(String.init)
            self.filePrefix = filePrefix
            self.fileSuffix = fileSuffix
            self.source = source
        }

        public static func evaluate(_ m: CommandMode) -> Result<Options, CommandantError<TorchGeneratorError>> {
            return curry(Options.init)
                <*> m <| Option(
                    key: "output",
                    defaultValue: "GeneratedTorchEntityExtensions.swift",
                    usage: "Where to put the generated extensions.\nIf a path to a directory is supplied, each input file will have a respective output file with extension.\nIf a path to a Swift file is supplied, all extensions will be in a single file.\nDefault value is `GeneratedTorchEntityExtensions.swift`.")

                <*> m <| Option(key: "no-header", defaultValue: false, usage: "Do not generate file headers.")
                <*> m <| Option(key: "no-timestamp", defaultValue: false, usage: "Do not generate timestamp.")

                <*> m <| Option(
                    key: "libraries",
                    defaultValue: "",
                    usage: "A comma separated list of libraries that should be imported in the generated file(s).")

                <*> m <| Option(
                    key: "file-prefix",
                    defaultValue: "",
                    usage: "Names of generated files in directory will start with this prefix. Only works when output path is directory.")

                <*> m <| Option(
                    key: "file-suffix",
                    defaultValue: "+Torch",
                    usage: "Names of generated filees in directory will end with this suffix. Only works when output path is a directory. Default value is `+Torch`")

                <*> m <| Argument(
                    usage: "Directory/File path where to look for TorchEntities. If supplied path represents directory then the search will be recursive. Search will be done only in files with .swift extension.")
        }
    }
}
