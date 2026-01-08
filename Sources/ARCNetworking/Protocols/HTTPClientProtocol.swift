//
//  HTTPClientProtocol.swift
//  ARCNetworking
//
//  Created by ARC Labs Studio on 24/10/25.
//

import Foundation

/// A protocol that defines HTTP client capabilities.
///
/// Conform to this protocol to create custom HTTP clients that can execute
/// endpoint requests and return decoded responses.
public protocol HTTPClientProtocol: Sendable {
    /// Executes an HTTP request for the given endpoint and returns the decoded response.
    ///
    /// - Parameter endpoint: The endpoint defining the request parameters.
    /// - Returns: The decoded response of the endpoint's associated `Response` type.
    /// - Throws: `HTTPError` if the request fails or the response cannot be decoded.
    func execute<T: Endpoint>(_ endpoint: T) async throws -> T.Response
}
