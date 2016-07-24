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
        context.rollback()
        return self
    }

    public func write(@noescape closure: () throws -> Void = {}) throws -> Database {
        try closure()
        try context.save()
        return self
    }
}