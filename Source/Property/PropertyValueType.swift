//
//  PropertyValueType.swift
//  Torch
//
//  Created by Filip Dolnik on 26.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import GRDB
import Foundation

// It is not possible to do DatabaseValueConvertible: PropertyType. Switch to this when possible.
public protocol PropertyValueType: PropertyType, DatabaseValueConvertible {
    static var databaseValueType: DatabaseValueType { get }
}

extension CGFloat: PropertyValueType {
    public static let databaseValueType: DatabaseValueType = .Real
}

extension Bool: PropertyValueType {
    public static let databaseValueType: DatabaseValueType = .Int
}

extension Int: PropertyValueType {
    public static let databaseValueType: DatabaseValueType = .Int
}

extension Int32: PropertyValueType {
    public static let databaseValueType: DatabaseValueType = .Int
}

extension Int64: PropertyValueType {
    public static let databaseValueType: DatabaseValueType = .Int
}

extension Double: PropertyValueType {
    public static let databaseValueType: DatabaseValueType = .Real
}

extension Float: PropertyValueType {
    public static let databaseValueType: DatabaseValueType = .Real
}

extension String: PropertyValueType {
    public static let databaseValueType: DatabaseValueType = .Text
}

extension NSData: PropertyValueType {
    public static let databaseValueType: DatabaseValueType = .Blob
}

extension NSDate: PropertyValueType {
    public static let databaseValueType: DatabaseValueType = .Text
}

extension NSNumber: PropertyValueType {
    public static let databaseValueType: DatabaseValueType = .Real
}

extension NSString: PropertyValueType {
    public static let databaseValueType: DatabaseValueType = .Text
}

extension NSURL: PropertyValueType {
    public static let databaseValueType: DatabaseValueType = .Text
}