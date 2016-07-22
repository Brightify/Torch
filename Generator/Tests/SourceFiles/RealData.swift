//
//  DataWithRelations.swift
//  TorchGenerator
//
//  Created by Filip Dolnik on 21.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

struct Data: TorchEntity {
    var id: Int?
    
    var number: Int
    var optionalNumber: Int?
    var numbers: [Int]
    
    var text: String
    var float: Float
    var double: Double
    var bool: Bool
    
    var set: Set<Int>
    
    var relation: OtherData
    var optionalRelation: OtherData?
    var arrayWithRelation: [OtherData]
    
    let readOnly: String
}

struct OtherData: TorchEntity {
    var id: Int?
    var text: String
}
