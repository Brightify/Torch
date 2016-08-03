//
//  PropertyValueTypeConvertible.swift
//  Torch
//
//  Created by Filip Dolnik on 03.08.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import RealmSwift

public protocol PropertyValueTypeConvertible: PropertyType {
    associatedtype ValueType: PropertyValueType
    
    static var defaultValue: Self { get }
    
    static func fromValue(value: ValueType) -> Self
    
    func toValue() -> ValueType
}