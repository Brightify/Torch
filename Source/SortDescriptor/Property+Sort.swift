//
//  Property+Sort.swift
//  Torch
//
//  Created by Tadeáš Kříž on 24/07/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Foundation

extension TorchProperty {
    var ascending: SortDescriptor<PARENT> {
        return SortDescriptor(keyPath: torchName, ascending: true)
    }

    var descending: SortDescriptor<PARENT> {
        return SortDescriptor(keyPath: torchName, ascending: false)
    }
}

extension TorchProperty where T: TorchEntity {
    func by(descriptor: SortDescriptor<T>) -> SortDescriptor<PARENT> {
        return SortDescriptor<PARENT>(keyPath: descriptor.keyPath, ascending: descriptor.ascending)
    }
}

extension TorchProperty where T: TorchPropertyOptionalType, T.Wrapped: TorchEntity {
    func by(descriptor: SortDescriptor<T>) -> SortDescriptor<PARENT> {
        return SortDescriptor<PARENT>(keyPath: descriptor.keyPath, ascending: descriptor.ascending)
    }
}
