//
//  StoreConfiguration.swift
//  Torch
//
//  Created by Filip Dolnik on 20.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Foundation

public struct StoreConfiguration {
    public let storeType: String
    public let configuration: String?
    public let storeURL: NSURL?
    public let options: [NSObject : AnyObject]?
}
