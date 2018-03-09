//
//  Metadata.swift
//  Torch
//
//  Created by Filip Dolnik on 20.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import RealmSwift

class Metadata: RealmSwift.Object {

    @objc
    dynamic var entityName: String = ""

    @objc
    dynamic var lastAssignedId: Int = -1
    
    override static func primaryKey() -> String? {
        return "entityName"
    }
}
