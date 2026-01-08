//
//  HTTPError.swift
//  ARCNetworking
//
//  Created by ARC Labs Studio on 24/10/25.
//

import Foundation

/// Errors that can occur during HTTP network operations.
public enum HTTPError: Error, LocalizedError, @unchecked Sendable {
    /// The URL provided was invalid or malformed.
    case invalidURL
    /// The HTTP request failed with a non-2xx status code.
    case requestFailed(Int)
    /// The response data could not be decoded to the expected type.
    case decodingFailed(Error)
    /// An unknown error occurred during the network operation.
    case unknown(Error)

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            "The URL provided was invalid."
        case let .requestFailed(code):
            "The request failed with status code \(code)."
        case let .decodingFailed(error):
            "Failed to decode response: \(error.localizedDescription)"
        case let .unknown(error):
            "Unknown error: \(error.localizedDescription)"
        }
    }
}
