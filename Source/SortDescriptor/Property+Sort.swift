//
//  Property+Sort.swift
//  Torch
//
//  Created by Tadeáš Kříž on 24/07/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Foundation
/*
extension Property {
    public var ascending: SortDescriptor<PARENT> {
        return SortDescriptor(keyPath: torchName, ascending: true)
    }

    public var descending: SortDescriptor<PARENT> {
        return SortDescriptor(keyPath: torchName, ascending: false)
    }
}

extension Property where T: TorchEntity {
    public func by(descriptor: SortDescriptor<T>) -> SortDescriptor<PARENT> {
        return SortDescriptor<PARENT>(keyPath: joinKeyPaths(torchName, descriptor.keyPath), ascending: descriptor.ascending)
    }
}

extension Property where T: PropertyOptionalType, T.Wrapped: TorchEntity {
    public func by(descriptor: SortDescriptor<T.Wrapped>) -> SortDescriptor<PARENT> {
        return SortDescriptor<PARENT>(keyPath: joinKeyPaths(torchName, descriptor.keyPath), ascending: descriptor.ascending)
    }
}
*/