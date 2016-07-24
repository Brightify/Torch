//
//  ApiDraft.swift
//  Torch
//
//  Created by Filip Dolnik on 19.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import CoreData

// TODO Finish
public struct SortDescriptor<PARENT> {

    public let keyPath: String
    public let ascending: Bool

    func toSortDescriptor() -> NSSortDescriptor {
        return NSSortDescriptor(key: keyPath, ascending: ascending)
    }
}

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
