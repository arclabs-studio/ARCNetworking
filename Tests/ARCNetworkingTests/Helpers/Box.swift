//
//  Box.swift
//  ARCNetworking
//
//  Created by ARC Labs Studio on 11/03/26.
//

import Foundation

/// A reference-type wrapper for mutable values in test closures.
///
/// Captures a mutable value across `@Sendable` closure boundaries in Swift Testing.
final class Box<T>: @unchecked Sendable {
    var value: T
    init(_ value: T) {
        self.value = value
    }
}
