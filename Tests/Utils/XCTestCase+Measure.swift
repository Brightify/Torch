//
//  XCTestCase+Measure.swift
//  Torch
//
//  Created by Filip Dolnik on 25.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import XCTest

extension XCTestCase {
    
    // TODO Use measureBlockWithSetup in Swift 3
    var performanceMetrics: [String] {
        return XCTestCase.defaultPerformanceMetrics()
    }
    
    func measure(@noescape block: () -> Void) {
        startMeasuring()
        block()
        stopMeasuring()
    }
}