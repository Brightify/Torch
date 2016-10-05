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

    // Has to be function, otherwise cannot be used in extensions.
    static func getDefaultValue() -> Self
    
    static func from(value: ValueType) -> Self
    
    func toValue() -> ValueType
}
