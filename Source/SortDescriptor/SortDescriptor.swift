//
//  SortDescriptor.swift
//  Torch
//
//  Created by Tadeáš Kříž on 24/07/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Foundation

public struct SortDescriptor<PARENT> {

    public let keyPath: String
    public let ascending: Bool

    func toSortDescriptor() -> NSSortDescriptor {
        return NSSortDescriptor(key: keyPath, ascending: ascending)
    }
}