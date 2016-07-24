//
//  SequencePropertyOperators.swift
//  Torch
//
//  Created by Tadeáš Kříž on 24/07/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Foundation

// MARK: - SequenceType<TorchEntity>
public extension TorchProperty where T: SequenceType, T.Generator.Element: TorchEntity {
    public func any(predicate: SingleValuePredicate<T.Generator.Element>) -> AggregatePredicate<PARENT> {
        return inside(.Any, predicate: predicate)
    }

    public func all(predicate: SingleValuePredicate<T.Generator.Element>) -> AggregatePredicate<PARENT> {
        return inside(.All, predicate: predicate)
    }

    public func none(predicate: SingleValuePredicate<T.Generator.Element>) -> AggregatePredicate<PARENT> {
        return inside(.None, predicate: predicate)
    }

    private func inside(type: AggregatePredicateType, predicate: SingleValuePredicate<T.Generator.Element>) -> AggregatePredicate<PARENT> {
        return AggregatePredicate(type: type,
                                  keyPath: joinKeyPaths(torchName, predicate.keyPath),
                                  operatorString: predicate.operatorString,
                                  value: predicate.value)
    }
}
