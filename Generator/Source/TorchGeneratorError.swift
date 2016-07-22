//
//  CuckooGeneratorError.swift
//  TorchGenerator
//
//  Created by Filip Dolnik on 21.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import FileKit

public enum TorchGeneratorError: ErrorType {
    case IOError(FileKitError)
    case UnknownError(ErrorType)
    
    public var description: String {
        switch self {
        case .IOError(let error):
            return error.description
        case .UnknownError(let error):
            return "\(error)"
        }
    }
}