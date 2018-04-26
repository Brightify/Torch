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

    public var transaction: TorchTransactionHelper {
        return TorchTransactionHelper(
            begin: realm.beginWrite,
            commit: { self.commit(errorHandler: self.defaultOnWriteError) },
            commitWithErrorHandler: commit(errorHandler:),
            rollback: rollback)
    }

    @discardableResult
    public func write(_ closure: (@escaping Rollback) -> Void) -> Database {
        return write(defaultOnWriteError, closure: closure)
    }

    @discardableResult
    public func write(_ onWriteError: OnWriteErrorListener, closure: (@escaping Rollback) -> Void) -> Database {
        realm.beginWrite()
        closure(rollback)
        // In case we rolled back
        guard realm.isInWriteTransaction else { return self }
        commit(errorHandler: onWriteError)
        return self
    }

    private func commit(errorHandler: OnWriteErrorListener) {
        do {
            try realm.commitWrite()
        } catch {
            errorHandler(error)
        }
    }

    private func rollback() {
        realm.cancelWrite()
        metadata = [:]
    }
}
