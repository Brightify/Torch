//
//  VersionCommand.swift
//  TorchGenerator
//
//  Created by Filip Dolnik on 21.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Commandant
import Result

public struct VersionCommand: CommandType {
    
    static let appVersion = NSBundle.allFrameworks().filter {
        $0.bundleIdentifier == "org.brightify.TorchGeneratorFramework"
        }.first?.objectForInfoDictionaryKey("CFBundleShortVersionString") as? String ?? ""
    
    public let verb = "version"
    public let function = "Prints the version of this generator."
    
    public func run(options: Options) -> Result<Void, TorchGeneratorError> {
        print(VersionCommand.appVersion)
        return .Success()
    }
    
    public struct Options: OptionsType {
        public static func evaluate(m: CommandMode) -> Result<Options, CommandantError<TorchGeneratorError>> {
            return .Success(Options())
        }
    }
}