//
//  SourceKittenFramework.swift
//  TorchGenerator
//
//  Created by Filip Dolnik on 21.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import SourceKittenFramework

public struct FileRepresentation {
    public let sourceFile: File
    public let declarations: [Token]
    public let containsTorchEntity: Bool
}