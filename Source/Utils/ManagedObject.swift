//
//  ManagedObject.swift
//  Torch
//
//  Created by Filip Dolnik on 02.08.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

public protocol ManagedObject: AnyObject {
    associatedtype IdType: TorchEntityId

    var id: IdType { get set }
}
