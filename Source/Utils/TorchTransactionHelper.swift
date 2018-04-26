//
//  TorchTransactionHelper.swift
//  Torch
//
//  Created by Tadeas Kriz on 26/04/2018.
//  Copyright © 2018 Brightify. All rights reserved.
//

public struct TorchTransactionHelper {
    internal typealias Begin = () -> Void
    internal typealias Commit = () -> Void
    internal typealias CommitWithErrorHandler = (Database.OnWriteErrorListener) -> Void
    internal typealias Rollback = () -> Void

    private let doBegin: Begin
    private let doCommit: Commit
    private let doCommitWithErrorHandler: CommitWithErrorHandler
    private let doRollback: Rollback

    internal init(begin: @escaping Begin,
                  commit: @escaping Commit,
                  commitWithErrorHandler: @escaping CommitWithErrorHandler,
                  rollback: @escaping Rollback) {
        self.doBegin = begin
        self.doCommit = commit
        self.doCommitWithErrorHandler = commitWithErrorHandler
        self.doRollback = rollback
    }

    public func begin() {
        doBegin()
    }

    public func commit() {
        doCommit()
    }

    public func commit(_ onWriteError: Database.OnWriteErrorListener) {
        doCommitWithErrorHandler(onWriteError)
    }

    public func rollback() {
        doRollback()
    }
}
