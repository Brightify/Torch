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