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

private func curry<P1, P2, P3, P4, P5, P6, P7, P8, P9, R>(f: (P1, P2, P3, P4, P5, P6, P7, P8, P9) -> R)
    -> (P1) -> (P2) -> (P3) -> (P4) -> (P5) -> (P6) -> (P7) -> (P8) -> (P9) -> R {
        return { p1 in { p2 in { p3 in { p4 in { p5 in { p6 in { p7 in { p8 in { p9 in f(p1, p2, p3, p4, p5, p6, p7, p8, p9) } } } } } } } } }
}

private func recursivelyExtractEntities(fromTokens tokens: [Token]) -> [StructDeclaration] {
    return tokens.flatMap { $0 as? StructDeclaration }.filter { $0.isEntityToken }.flatMap {
        [$0] + recursivelyExtractEntities(fromTokens: $0.children)
    }
}

public struct GenerateMocksCommand: CommandType {
    
    public let verb = "generate"
    public let function = "Generates files with TorchEntities extensions"
    
    public func run(options: Options) -> Result<Void, TorchGeneratorError> {
        let inputPath = Path(options.source)
        let outputPath = Path(options.output)
        let inputFiles = getInputFiles(inputPath)
        let parsedFiles = inputFiles.map { Tokenizer(sourceFile: $0).tokenize() }.filter { $0.containsTorchEntity }
        let allEntities = recursivelyExtractEntities(fromTokens: parsedFiles.flatMap { $0.declarations })
        let generator = Generator(moduleName: options.moduleName, allEntities: allEntities)
        let filesContent = generateFilesContent(parsedFiles, generator: generator, options: options)

        let files = zip(parsedFiles.map(resultFileName(options)), filesContent).map { (name: $0, content: $1) }
        let filesToWrite: [(name: String, content: String)]
        let bundle = generator.generateBundle(allEntities)

        // If we are generating into a single file
        if outputPath.isDirectory {
            filesToWrite = files + [(name: bundle.name, content: "import Torch\n\n\(bundle.content)")]
        } else {
            let fileContent = files.map { $0.content }.joinWithSeparator("\n") + "\n\(bundle.content)"
            filesToWrite = [(name: "", content: fileContent)]
        }

        return writeData(filesToWrite, outputPath: outputPath)
    }

    private func resultFileName(options: Options) -> (file: FileRepresentation) -> String {
        return { file in
            let path = self.appendPrefixAndSuffix(file.sourceFile.path ?? "Unknown", options: options)
            return Path(path).fileName
        }
    }

    private func appendPrefixAndSuffix(path: String, options: Options) -> String {
        let nsstringPath = path as NSString
        let fileName = Path(nsstringPath.stringByDeletingPathExtension).fileName
        let fileExtension = "." + nsstringPath.pathExtension
        return options.filePrefix + fileName + options.fileSuffix + fileExtension
    }

    private func getInputFiles(path: Path) -> [SourceKittenFramework.File] {
        if path.isDirectory {
            return path.find { $0.pathExtension == "swift"}.map { File(path: $0.standardRawValue) }.flatMap { $0 }
        } else {
            return [File(path: path.standardRawValue)].flatMap { $0 }
        }
    }
    
    private func generateFilesContent(parsedFiles: [FileRepresentation], generator: Generator, options: Options) -> [String] {
        let headers = parsedFiles.map { options.noHeader ? "" : FileHeaderHandler.getHeader($0, withTimestamp: !options.noTimestamp) }
        let imports = parsedFiles.map { FileHeaderHandler.getImports($0, libraries: options.libraries) }
        let extensions: [String] = parsedFiles.map {
            let entitiesInFile = recursivelyExtractEntities(fromTokens: $0.declarations)
            return generator.generate(entitiesInFile)
        }
        
        return zip(zip(headers, imports), extensions).map { "\($0.0)\($0.1)\($1)" }
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
        let output: String
        let noHeader: Bool
        let noTimestamp: Bool
        let noBundle: Bool
        let libraries: [String]
        let filePrefix: String
        let fileSuffix: String
        let moduleName: String
        let source: String

        public init(output: String,
                    noHeader: Bool,
                    noTimestamp: Bool,
                    noBundle: Bool,
                    libraries: String,
                    filePrefix: String,
                    fileSuffix: String,
                    moduleName: String,
                    source: String) {

            self.output = output
            self.noHeader = noHeader
            self.noTimestamp = noTimestamp
            self.noBundle = noBundle
            self.libraries = libraries.characters.split { $0 == "," }.map(String.init)
            self.filePrefix = filePrefix
            self.fileSuffix = fileSuffix
            self.moduleName = moduleName
            self.source = source
        }
        
        public static func evaluate(m: CommandMode) -> Result<Options, CommandantError<TorchGeneratorError>> {
            return curry(Options.init)
                <*> m <| Option(
                    key: "output",
                    defaultValue: "GeneratedTorchEntityExtensions.swift",
                    usage: "Where to put the generated extensions.\nIf a path to a directory is supplied, each input file will have a respective output file with extension.\nIf a path to a Swift file is supplied, all extensions will be in a single file.\nDefault value is `GeneratedTorchEntityExtensions.swift`.")

                <*> m <| Option(key: "no-header", defaultValue: false, usage: "Do not generate file headers.")
                <*> m <| Option(key: "no-timestamp", defaultValue: false, usage: "Do not generate timestamp.")
                <*> m <| Option(key: "no-bundle", defaultValue: false, usage: "Do not generate TorchEntityBundle.")

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

                <*> m <| Option(
                    key: "module-name",
                    defaultValue: "UserProject",
                    usage: "Name of module entities are from. It is used to prefix generated entity names and bundle. It is recommended to use `PRODUCT_MODULE_NAME` env property supplied by Xcode. Default value is `UserProject`.")

                <*> m <| Argument(
                    usage: "Directory/File path where to look for TorchEntities. If supplied path represents directory then the search will be recursive. Search will be done only in files with .swift extension.")
        }
    }
}