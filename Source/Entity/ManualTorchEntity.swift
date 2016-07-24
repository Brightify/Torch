//
//  ManualTorchEntity.swift
//  Torch
//
//  Created by Tadeáš Kříž on 24/07/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

/**
 In the case of Generator not being able to describe your entity properly,
 you can implement this protocol instead and write the description yourself.
 Torch will then treat the type as any other entity.
 */
public protocol ManualTorchEntity: TorchEntity { }
