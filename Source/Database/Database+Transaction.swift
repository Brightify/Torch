//
//  Database+Transaction.swift
//  Torch
//
//  Created by Tadeáš Kříž on 24/07/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Foundation

extension Database {
    public typealias Rollback = () -> Void

    @discardableResult
    public func write(_ closure: (@escaping Rollback) -> Void = { _ in }) -> Database {
        return write(defaultOnWriteError, closure: closure)
    }

    @discardableResult
    public func write(_ onWriteError: OnWriteErrorListener, closure: (@escaping Rollback) -> Void) -> Database {
        realm.beginWrite()
        closure(rollback)
        // In case we rolled back
        guard realm.isInWriteTransaction else { return self }
        do {
            try realm.commitWrite()
        } catch {
            onWriteError(error)
        }
        return self
    }

    public func rollback() {
        realm.cancelWrite()
        metadata = [:]
    }
}
