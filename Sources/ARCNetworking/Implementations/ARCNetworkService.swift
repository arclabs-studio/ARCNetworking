//
//  ARCNetworkService.swift
//  ARCNetworking
//
//  Created by ARC Labs Studio on 24/10/25.
//

import Foundation

/// A high-level network service that provides a simplified interface for HTTP requests.
///
/// `ARCNetworkService` wraps an ``HTTPClientProtocol`` and provides a clean API
/// for dependency injection and testing.
///
/// ## Example
///
/// ```swift
/// let service = ARCNetworkService()
/// let user = try await service.request(GetUserEndpoint(userId: "123"))
/// ```
public final class ARCNetworkService: ARCNetworkServiceProtocol {
    // MARK: Private Properties

    private let client: HTTPClientProtocol

    // MARK: Initialization

    /// Creates a network service with the specified HTTP client.
    ///
    /// - Parameter client: The HTTP client to use for requests. Defaults to `HTTPClient()`.
    public init(client: HTTPClientProtocol = HTTPClient()) {
        self.client = client
    }

    // MARK: Public Functions

    /// Performs a network request for the given endpoint and returns the decoded response.
    ///
    /// Delegates execution to the underlying ``HTTPClientProtocol`` implementation.
    ///
    /// - Parameter endpoint: The endpoint describing the HTTP request.
    /// - Returns: The decoded `T.Response`.
    /// - Throws: Any ``HTTPError`` thrown by the underlying client.
    public func request<T: Endpoint>(_ endpoint: T) async throws -> T.Response {
        try await client.execute(endpoint)
    }
}
