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
    
    public init(storeType: String, configuration:String?, storeURL: NSURL?, options: [NSObject : AnyObject]?) {
        self.storeType = storeType
        self.configuration = configuration
        self.storeURL = storeURL
        self.options = options
    }
}
