//
//  Accessibility.swift
//  TorchGenerator
//
//  Created by Filip Dolnik on 21.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

public enum Accessibility: String {
    case Public = "source.lang.swift.accessibility.public"
    case Internal = "source.lang.swift.accessibility.internal"
    case Private = "source.lang.swift.accessibility.private"
    
    public var sourceName: String {
        switch self {
        case .Public:
            return "public"
        case .Internal:
            return "internal"
        case .Private:
            return "private"
        }
    }

    public func isMoreOpenThan(accessibility: Accessibility) -> Bool {
        switch (self, accessibility) {
        case (.Public, .Internal), (.Public, .Private), (.Internal, .Private):
            return true
        default:
            return false
        }
    }
}
