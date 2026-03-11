//
//  AuthenticationInterceptor.swift
//  ARCNetworking
//
//  Created by ARC Labs Studio on 11/03/26.
//

import Foundation

/// An interceptor that injects a Bearer token into every outgoing request.
///
/// The token is fetched lazily via an async `tokenProvider` closure, making it
/// compatible with Firebase Auth, Keychain-backed tokens, or any async source.
/// The `Authorization` header is always overwritten — existing values are replaced.
///
/// ## Example
///
/// ```swift
/// let auth = AuthenticationInterceptor {
///     try await Auth.auth().currentUser?.getIDToken() ?? ""
/// }
/// let client = HTTPClient(interceptors: [auth])
/// ```
public struct AuthenticationInterceptor: RequestInterceptor {
    // MARK: Private Properties

    private let tokenProvider: @Sendable () async throws -> String

    // MARK: Initialization

    /// Creates an authentication interceptor with the specified token provider.
    ///
    /// - Parameter tokenProvider: An async closure that returns the Bearer token string.
    public init(tokenProvider: @Sendable @escaping () async throws -> String) {
        self.tokenProvider = tokenProvider
    }

    // MARK: RequestInterceptor

    /// Fetches the Bearer token from `tokenProvider` and injects it as the
    /// `Authorization` header before forwarding the request down the chain.
    ///
    /// - SeeAlso: ``RequestInterceptor/intercept(_:next:)``
    // swiftformat:disable wrapArguments
    public func intercept(_ request: URLRequest,
                          next: @Sendable (URLRequest) async throws -> (Data, HTTPURLResponse)) async throws
    -> (Data, HTTPURLResponse) {
        // swiftformat:enable wrapArguments
        let token = try await tokenProvider()
        var mutableRequest = request
        mutableRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return try await next(mutableRequest)
    }
}
