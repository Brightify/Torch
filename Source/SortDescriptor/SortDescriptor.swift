//
//  SortDescriptor.swift
//  Torch
//
//  Created by Tadeáš Kříž on 24/07/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import RealmSwift

public struct SortDescriptor<PARENT: TorchEntity> {

    fileprivate let sortDescriptors: [RealmSwift.SortDescriptor]

    init(property: String, ascending: Bool) {
        sortDescriptors = [RealmSwift.SortDescriptor(property: property, ascending: ascending)]
    }
    
    init<P, T: PropertyType>(parentProperty: Property<PARENT, T>, sortDescriptor: SortDescriptor<P>) {
        self.sortDescriptors = sortDescriptor.sortDescriptors.map {
            RealmSwift.SortDescriptor(property: parentProperty.name + "." + $0.property, ascending: $0.ascending)
        }
    }
    
    fileprivate init(sortDescriptors: [RealmSwift.SortDescriptor]) {
        self.sortDescriptors = sortDescriptors
    }
    
    public func then(_ sortDescriptor: SortDescriptor) -> SortDescriptor {
        return SortDescriptor(sortDescriptors: sortDescriptors + sortDescriptor.sortDescriptors)
    }
    
    func toSortDescriptors() -> [RealmSwift.SortDescriptor] {
        return sortDescriptors
    }
}
