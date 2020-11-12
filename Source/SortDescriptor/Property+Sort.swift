//
//  Property+Sort.swift
//  Torch
//
//  Created by Tadeáš Kříž on 24/07/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

// TODO Fix for TorchEntity
public extension Property {
    var ascending: SortDescriptor<PARENT> {
        return SortDescriptor(property: name, ascending: true)
    }

    var descending: SortDescriptor<PARENT> {
        return SortDescriptor(property: name, ascending: false)
    }
}

public extension Property where T: TorchEntity {
    
    func by(_ descriptor: SortDescriptor<T>) -> SortDescriptor<PARENT> {
        return SortDescriptor<PARENT>(parentProperty: self, sortDescriptor: descriptor)
    }
}

public extension Property where T: PropertyOptionalType, T.Wrapped: TorchEntity {
    
    func by(_ descriptor: SortDescriptor<T.Wrapped>) -> SortDescriptor<PARENT> {
        return SortDescriptor<PARENT>(parentProperty: self, sortDescriptor: descriptor)
    }
}
