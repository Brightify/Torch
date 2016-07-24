//
//  StoreConfiguration.swift
//  Torch
//
//  Created by Filip Dolnik on 20.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import CoreData

public struct StoreConfiguration {
    public let concurencyType: NSManagedObjectContextConcurrencyType
    public let storeType: String
    public let configuration: String?
    public let storeURL: NSURL?
    public let options: [NSObject : AnyObject]?

    public init(concurencyType: NSManagedObjectContextConcurrencyType = .MainQueueConcurrencyType,
                storeType: String,
                configuration:String? = nil,
                storeURL: NSURL? = nil,
                options: [NSObject : AnyObject]? = nil) {
        self.concurencyType = concurencyType
        self.storeType = storeType
        self.configuration = configuration
        self.storeURL = storeURL
        self.options = options
    }
}
