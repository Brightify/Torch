//
//  NSObjectConvertible.swift
//  Torch
//
//  Created by Filip Dolnik on 22.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Foundation

public protocol NSObjectConvertible: TorchPropertyType {
    
    init?(fromObject object: AnyObject)
    
    func toNSObject() -> NSObject
}

extension String: NSObjectConvertible {
    
    public init?(fromObject object: AnyObject) {
        if let string = object as? String {
            self = string
        } else {
            return nil
        }
    }
    
    public func toNSObject() -> NSObject {
        return self as NSString
    }
}