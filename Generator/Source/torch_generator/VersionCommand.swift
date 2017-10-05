//
//  VersionCommand.swift
//  TorchGenerator
//
//  Created by Filip Dolnik on 21.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Commandant
import Result
import Foundation

public struct VersionCommand: CommandProtocol {

    static let appVersion = Bundle.allFrameworks.filter {
        $0.bundleIdentifier == "org.brightify.TorchGeneratorFramework"
        }.first?.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""

    public let verb = "version"
    public let function = "Prints the version of this generator."

    public func run(_ options: Options) -> Result<Void, TorchGeneratorError> {
        print(VersionCommand.appVersion)
        return .success(())
    }

    public struct Options: OptionsProtocol {
        public static func evaluate(_ m: CommandMode) -> Result<Options, CommandantError<TorchGeneratorError>> {
            return .success(Options())
        }
    }
}
