//
//  String+Predicate.swift
//  Torch
//
//  Created by Tadeas Kriz on 7/5/17.
//  Copyright © 2017 Brightify. All rights reserved.
//

#if swift(>=3.1)
    public struct StringComparsionOptions: OptionSet, CustomStringConvertible {
        public static let caseInsensitive = StringComparsionOptions(rawValue: 1 << 0)
        public static let diacriticsInsensitive = StringComparsionOptions(rawValue: 1 << 1)

        public let rawValue: Int

        public var description: String {
            var flags = [] as [String]
            if self.contains(.caseInsensitive) {
                flags.append("c")
            }
            if self.contains(.diacriticsInsensitive) {
                flags.append("d")
            }
            guard !flags.isEmpty else { return "" }
            return "[\(flags.joined())]"
        }

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }

    public extension Property where T == String {
        public func hasPrefix(_ value: T, options: StringComparsionOptions = []) -> Predicate<PARENT> {
            return Predicate.singleValuePredicate(name, value: value.toAnyObject(), operatorString: "BEGINSWITH\(options)")
        }

        public func hasSuffix(_ value: T, options: StringComparsionOptions = []) -> Predicate<PARENT> {
            return Predicate.singleValuePredicate(name, value: value.toAnyObject(), operatorString: "ENDSWITH\(options)")
        }

        public func contains(_ value: T, options: StringComparsionOptions = []) -> Predicate<PARENT> {
            return Predicate.singleValuePredicate(name, value: value.toAnyObject(), operatorString: "CONTAINS\(options)")
        }

        public func like(_ value: T, options: StringComparsionOptions = []) -> Predicate<PARENT> {
            return Predicate.singleValuePredicate(name, value: value.toAnyObject(), operatorString: "LIKE\(options)")
        }

        public func matches(regex: T, options: StringComparsionOptions = []) -> Predicate<PARENT> {
            return Predicate.singleValuePredicate(name, value: regex.toAnyObject(), operatorString: "MATCHES\(options)")
        }

        public func equalTo(_ value: T, options: StringComparsionOptions) -> Predicate<PARENT> {
            return Predicate.singleValuePredicate(name, value: value.toAnyObject(), operatorString: "==\(options)")
        }

        public func notEqualTo(_ value: T, options: StringComparsionOptions) -> Predicate<PARENT> {
            return Predicate.singleValuePredicate(name, value: value.toAnyObject(), operatorString: "!=\(options)")
        }

        public func lessThan(_ value: T, options: StringComparsionOptions) -> Predicate<PARENT> {
            return Predicate.singleValuePredicate(name, value: value.toAnyObject(), operatorString: "<\(options)")
        }

        public func lessThanOrEqualTo(_ value: T, options: StringComparsionOptions) -> Predicate<PARENT> {
            return Predicate.singleValuePredicate(name, value: value.toAnyObject(), operatorString: "<=\(options)")
        }

        public func greaterThanOrEqualTo(_ value: T, options: StringComparsionOptions) -> Predicate<PARENT> {
            return Predicate.singleValuePredicate(name, value: value.toAnyObject(), operatorString: ">=\(options)")
        }

        public func greaterThan(_ value: T, options: StringComparsionOptions) -> Predicate<PARENT> {
            return Predicate.singleValuePredicate(name, value: value.toAnyObject(), operatorString: ">\(options)")
        }
    }
#endif
