//
//  CuckooGeneratorError.swift
//  TorchGenerator
//
//  Created by Filip Dolnik on 21.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import FileKit

public enum TorchGeneratorError: Error {
    case ioError(FileKitError)
    case unknownError(Error)
    
    public var description: String {
        switch self {
        case .ioError(let error):
            return error.description
        case .unknownError(let error):
            return "\(error)"
        }
    }
}
