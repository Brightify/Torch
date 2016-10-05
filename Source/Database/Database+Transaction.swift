//
//  Database+Transaction.swift
//  Torch
//
//  Created by Tadeáš Kříž on 24/07/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Foundation

extension Database {

    @discardableResult
    public func rollback() -> Database {
        realm.cancelWrite()
        metadata = [:]
        realm.beginWrite()
        return self
    }

    @discardableResult
    public func write(_ closure: () -> Void = {}) -> Database {
        return write(defaultOnWriteError, closure: closure)
    }

    @discardableResult
    public func write(_ onWriteError: OnWriteErrorListener, closure: () -> Void = {}) -> Database {
        closure()
        do {
            try realm.commitWrite()
        } catch {
            onWriteError(error)
        }
        if !realm.isInWriteTransaction {
            realm.beginWrite()
        }
        return self
    }
}
