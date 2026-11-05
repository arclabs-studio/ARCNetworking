//
//  URL+Fixture.swift
//  ARCNetworking
//
//  Created by ARC Labs Studio on 05/11/26.
//

import Foundation

extension URL {
    /// Parses a URL literal used as a test fixture. A literal that does not parse fails loudly.
    static func fixture(_ string: String) -> URL {
        guard let url = URL(string: string) else {
            preconditionFailure("Invalid fixture URL literal: \(string)")
        }
        return url
    }
}
