//
//  Models.swift
//  Torch
//
//  Created by Filip Dolnik on 22.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Torch
import RealmSwift

struct Data: TorchEntity {
    var id: Int?
    
    var number: Int
    var optionalNumber: Int?
    var numbers: [Int]
    
    var text: String
    var optionalString: String?
    
    var float: Float
    var double: Double
    var bool: Bool
    
    var relation: OtherData?
    var arrayWithRelation: [OtherData]
    
    let readOnly: String
}

struct OtherData: TorchEntity {
    var id: Int?
    var text: String
}

struct DataWithEnums: TorchEntity {
    var id: Int?
    var planet: Planet
    var optionalPlanet: Planet?
    var day: Day
    var optionalDay: Day?
    var days: [Day]
}

enum Planet: Int {
    case Mercury, Venus, Earth, Mars, Jupiter, Saturn, Uranus, Neptune
}

extension Planet: PropertyValueTypeConvertible {
    
    static func getDefaultValue() -> Planet {
        return Planet.Mercury
    }
    
    static func fromValue(value: Int) -> Planet {
        return Planet(rawValue: value)!
    }
    
    func toValue() -> Int {
        return rawValue
    }
}

enum Day: String {
    case Monday = "Monday"
    case Tuesday = "Tuesday"
    case Wednesday = "Wednesday"
    case Thursday = "Thursday"
    case Friday = "Friday"
    case Saturday = "Saturday"
    case Sunday = "Sunday"
}

extension Day: PropertyValueTypeConvertible {
    
    static func getDefaultValue() -> Day {
        return Day.Monday
    }
    
    static func fromValue(value: String) -> Day {
        return Day(rawValue: value)!
    }
    
    func toValue() -> String {
        return rawValue
    }
}