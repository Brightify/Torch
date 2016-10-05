//
//  Database+Load.swift
//  Torch
//
//  Created by Tadeáš Kříž on 24/07/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

public extension Database {
    
    public func load<T: TorchEntity>(_ type: T.Type) -> [T] {
        return realm.objects(T.ManagedObjectType.self).map { T(fromManagedObject: $0) }
    }
    
    public func load<T: TorchEntity>(_ type: T.Type, where predicate: Predicate<T>) -> [T] {
        return realm.objects(T.ManagedObjectType.self).filter(predicate.toPredicate()).map { T(fromManagedObject: $0) }
    }
    
    public func load<T: TorchEntity>(_ type: T.Type, sortBy sortDescriptor: SortDescriptor<T>) -> [T] {
        return realm.objects(T.ManagedObjectType.self).sorted(by: sortDescriptor.toSortDescriptors()).map { T(fromManagedObject: $0) }
    }

    public func load<T: TorchEntity>(_ type: T.Type, where predicate: Predicate<T>, sortBy sortDescriptor: SortDescriptor<T>) -> [T] {
        return realm.objects(T.ManagedObjectType.self).filter(predicate.toPredicate()).sorted(by: sortDescriptor.toSortDescriptors()).map { T(fromManagedObject: $0) }
    }
}
