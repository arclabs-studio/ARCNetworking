//
//  ARCNetworkServiceProtocol.swift
//  ARCNetworking
//
//  Created by ARC Labs Studio on 24/10/25.
//

import Foundation

/// A protocol that defines high-level network service capabilities.
///
/// Conform to this protocol to create network services that can be injected
/// as dependencies for testability.
public protocol ARCNetworkServiceProtocol: Sendable {
    /// Performs a network request for the given endpoint and returns the decoded response.
    ///
    /// - Parameter endpoint: The endpoint defining the request parameters.
    /// - Returns: The decoded response of the endpoint's associated `Response` type.
    /// - Throws: `HTTPError` if the request fails or the response cannot be decoded.
    func request<T: Endpoint>(_ endpoint: T) async throws -> T.Response
}
