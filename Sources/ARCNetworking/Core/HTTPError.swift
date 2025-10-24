//
//  HTTPError.swift
//  ARCNetworking
//
//  Created by ARC Labs on 24/10/25.
//

import Foundation

public enum HTTPError: Error, LocalizedError {
    case invalidURL
    case requestFailed(Int)
    case decodingFailed(Error)
    case unknown(Error)
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL: return "The URL provided was invalid."
        case .requestFailed(let code): return "The request failed with status code \(code)."
        case .decodingFailed(let error): return "Failed to decode response: \(error.localizedDescription)"
        case .unknown(let error): return "Unknown error: \(error.localizedDescription)"
        }
    }
}

