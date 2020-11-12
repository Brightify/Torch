//
//  Property+Predicate.swift
//  Torch
//
//  Created by Filip Dolnik on 31.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

public extension Property where T: TorchEntity {
    
    subscript(predicate: Predicate<T>) -> Predicate<PARENT> {
        return matches(predicate)
    }
    
    func matches(_ predicate: Predicate<T>) -> Predicate<PARENT> {
        return Predicate.parentPropertyPredicate(self, predicate: predicate)
    }
}

public extension Property where T: PropertyOptionalType, T.Wrapped: TorchEntity {
    
    subscript(predicate: Predicate<T.Wrapped>) -> Predicate<PARENT> {
        return matches(predicate)
    }
    
    func matches(_ predicate: Predicate<T.Wrapped>) -> Predicate<PARENT> {
        return Predicate.parentPropertyPredicate(self, predicate: predicate)
    }
}
