//
//  Box.swift
//  ARCNetworking
//
//  Created by ARC Labs Studio on 11/03/26.
//

import Foundation
import os

/// A reference-type wrapper for mutable values in test closures.
///
/// Captures a mutable value across `@Sendable` closure boundaries in Swift Testing.
final class Box<T: Sendable>: Sendable {
    private let storage: OSAllocatedUnfairLock<T>

    var value: T {
        get { storage.withLock { $0 } }
        set { storage.withLock { $0 = newValue } }
    }

    init(_ value: T) {
        storage = OSAllocatedUnfairLock(initialState: value)
    }

    /// Mutates the value atomically, so read-modify-write updates cannot interleave.
    func update(_ body: @Sendable (inout T) -> Void) {
        storage.withLock { body(&$0) }
    }
}
