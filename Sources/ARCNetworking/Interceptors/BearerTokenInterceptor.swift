//
//  BearerTokenInterceptor.swift
//  ARCNetworking
//
//  Created by ARC Labs Studio on 18/03/26.
//

import Foundation

/// An interceptor that injects a Bearer token into the `Authorization` header using a synchronous token provider.
///
/// Use ``BearerTokenInterceptor`` when token generation is CPU-bound and does not require `await`
/// (e.g. signing a JWT with a local private key). For async token sources such as Firebase or
/// network-backed token refresh, use ``AuthenticationInterceptor`` instead.
///
/// ## Example
///
/// ```swift
/// let client = HTTPClient(interceptors: [
///     BearerTokenInterceptor { try JWTSigner.sign(claims: myClaims) },
///     LoggingInterceptor()
/// ])
/// ```
public struct BearerTokenInterceptor: RequestInterceptor {
    // MARK: Private Properties

    private let tokenProvider: @Sendable () throws -> String

    // MARK: Initialization

    /// Creates a Bearer token interceptor with the given synchronous token provider.
    ///
    /// - Parameter tokenProvider: A throwing closure that returns the raw token string.
    ///   Called once per request, immediately before forwarding to the next interceptor.
    public init(tokenProvider: @escaping @Sendable () throws -> String) {
        self.tokenProvider = tokenProvider
    }

    // MARK: RequestInterceptor

    // swiftformat:disable wrapArguments
    /// Injects `Authorization: Bearer <token>` and forwards the mutated request.
    ///
    /// Any existing `Authorization` header value is overwritten.
    /// If `tokenProvider` throws, the error propagates immediately and the chain is short-circuited.
    ///
    /// - SeeAlso: ``RequestInterceptor/intercept(_:next:)``
    public func intercept(_ request: URLRequest,
                          next: @Sendable (URLRequest) async throws -> (Data, HTTPURLResponse)) async throws
    -> (Data, HTTPURLResponse) {
        // swiftformat:enable wrapArguments
        var mutableRequest = request
        try mutableRequest.setValue("Bearer \(tokenProvider())", forHTTPHeaderField: "Authorization")
        return try await next(mutableRequest)
    }
}
