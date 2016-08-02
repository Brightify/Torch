//
//  Database+Transaction.swift
//  Torch
//
//  Created by Tadeáš Kříž on 24/07/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Foundation

extension Database {
    
    public func rollback() -> Database {
        realm.cancelWrite()
        metadata = [:]
        realm.beginWrite()
        return self
    }

    public func write(@noescape closure: () -> Void = {}) -> Database {
        return write(defaultOnWriteError, closure: closure)
    }
    
    public func write(@noescape onWriteError: OnWriteErrorListener, @noescape closure: () -> Void = {}) -> Database {
        closure()
        do {
            try realm.commitWrite()
        } catch {
            onWriteError(error)
        }
        if !realm.inWriteTransaction {
            realm.beginWrite()
        }
        return self
    }
}