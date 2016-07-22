//
//  MultipleData.swift
//  TorchGenerator
//
//  Created by Filip Dolnik on 21.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

struct Data: TorchEntity {
	var id: Int?
}

struct Struct {
}

struct Data2: TorchEntity {
	var id: Int?

	let readOnlyRelation: Data
}