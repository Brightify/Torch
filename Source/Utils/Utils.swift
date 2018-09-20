//
//  Utils.swift
//  Torch
//
//  Created by Filip Dolnik on 01.08.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import RealmSwift

public struct Utils {
    
    static func getIsNilVariableName(_ variableName: String) -> String {
        return variableName + "_isNil"
    }
    
    public static func toValue<T: PropertyValueType>(_ managedValue: T) -> T {
        return managedValue
    }
    
    public static func toValue<T: PropertyValueTypeConvertible>(_ managedValue: T.ValueType) -> T {
        return T.from(value: managedValue)
    }
    
    // For ID
    public static func toValue<T: PropertyValueType>(_ managedValue: T) -> T? {
        return managedValue
    }
    
    public static func toValue<T: PropertyValueType>(_ managedValue: RealmOptional<T>) -> T? {
        return managedValue.value
    }
    
    public static func toValue<T: PropertyOptionalType>(_ managedValue: T) -> T where T.Wrapped: PropertyValueType {
        return managedValue
    }
    
    public static func toValue<T: PropertyValueTypeConvertible>(_ managedValue: T.ValueType, _ isNil: Bool) -> T? {
        return isNil ? nil : T.from(value: managedValue)
    }
    
    public static func toValue<T: PropertyValueType, V: ValueTypeWrapper>(_ managedValue: List<V>) -> [T] where V.ValueType == T {
        return managedValue.map { $0.value }
    }
    
    public static func toValue<T: PropertyValueTypeConvertible, V: ValueTypeWrapper>(_ managedValue: List<V>) -> [T] where V.ValueType == T.ValueType {
        return managedValue.map { T.from(value: $0.value) }
    }
    
    public static func toValue<T: TorchEntity>(_ managedValue: T.ManagedObjectType?) -> T? {
        if let managedValue = managedValue {
            return T(fromManagedObject: managedValue)
        } else {
            return nil
        }
    }
    
    public static func toValue<T: TorchEntity>(_ managedValue: List<T.ManagedObjectType>) -> [T] {
        return managedValue.map { T(fromManagedObject: $0) }
    }
    
    public static func updateManagedValue<T: PropertyValueType>(_ managedValue: inout T, _ value: T) {
        managedValue = value
    }
    
    public static func updateManagedValue<T: PropertyValueTypeConvertible>(_ managedValue: inout T.ValueType, _ value: T) {
        managedValue = value.toValue()
    }
    
    public static func updateManagedValue<T: PropertyValueType>(_ managedValue: inout RealmOptional<T>, _ value: T?) {
        managedValue.value = value
    }

    public static func updateManagedValue<T: PropertyOptionalType>(_ managedValue: inout T, _ value: T) where T.Wrapped: PropertyValueType {
        managedValue = value
    }
    
    public static func updateManagedValue<T: PropertyOptionalType>(_ managedValue: inout T.Wrapped.ValueType, _ isNil: inout Bool, _ value: T) where T.Wrapped: PropertyValueTypeConvertible {
        if let value = value.value {
            managedValue = value.toValue()
            isNil = false
        } else {
            isNil = true
        }
    }
    
//    public static func updateManagedValue<T: PropertyValueType, V: ValueTypeWrapper>(_ managedValue: inout List<V>, _ value: [T]) where V.ValueType == T {
//        managedValue.realm?.delete(managedValue)
//        managedValue.removeAll()
//        value.map {
//            let wrapper = V()
//            wrapper.value = $0
//            return wrapper
//        }.forEach { managedValue.append($0) }
//    }
//
//    public static func updateManagedValue<T: PropertyValueTypeConvertible, V: ValueTypeWrapper>
//        (_ managedValue: inout List<V>, _ value: [T]) where V.ValueType == T.ValueType {
//        managedValue.realm?.delete(managedValue)
//        managedValue.removeAll()
//        value.map {
//            let wrapper = V()
//            wrapper.value = $0.toValue()
//            return wrapper
//            }.forEach { managedValue.append($0) }
//    }
//
    public static func updateManagedValue<T: TorchEntity>(_ managedValue: inout T.ManagedObjectType?, _ value: inout T?, _ database: Database) where T.IdType == Int {
        if var unwrapedValue = value {
            managedValue = database.getManagedObject(&unwrapedValue, assignId: database.assignId)
            value = unwrapedValue
        } else {
            managedValue = nil
        }
    }

    public static func updateManagedValue<T: TorchEntity>(_ managedValue: inout T.ManagedObjectType?, _ value: inout T?, _ database: Database) where T.IdType == String {
        if var unwrapedValue = value {
            managedValue = database.getManagedObject(&unwrapedValue, assignId: database.assignId)
            value = unwrapedValue
        } else {
            managedValue = nil
        }
    }
    
    public static func updateManagedValue<T: TorchEntity>(_ managedValue: inout List<T.ManagedObjectType>, _ value: inout [T], _ database: Database) where T.IdType == Int {
        managedValue.removeAll()
        for i in value.indices {
            managedValue.append(database.getManagedObject(&value[i], assignId: database.assignId))
        }
    }

    public static func updateManagedValue<T: TorchEntity>(_ managedValue: inout List<T.ManagedObjectType>, _ value: inout [T], _ database: Database) where T.IdType == String {
        managedValue.removeAll()
        for i in value.indices {
            managedValue.append(database.getManagedObject(&value[i], assignId: database.assignId))
        }
    }
}
