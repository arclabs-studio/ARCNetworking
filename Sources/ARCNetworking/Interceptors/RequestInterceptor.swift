//
//  RequestInterceptor.swift
//  ARCNetworking
//
//  Created by ARC Labs Studio on 11/03/26.
//

import Foundation

/// A middleware that can inspect, mutate, or short-circuit HTTP requests and responses.
///
/// Interceptors are composed into a chain and executed in declaration order.
/// Each interceptor receives the outgoing `URLRequest` and a `next` closure that
/// forwards execution to the subsequent interceptor (or the transport layer).
///
/// ## Example
///
/// ```swift
/// struct TimestampInterceptor: RequestInterceptor {
///     func intercept(
///         _ request: URLRequest,
///         next: @Sendable (URLRequest) async throws -> (Data, HTTPURLResponse)
///     ) async throws -> (Data, HTTPURLResponse) {
///         var mutableRequest = request
///         mutableRequest.setValue(Date().ISO8601Format(), forHTTPHeaderField: "X-Timestamp")
///         return try await next(mutableRequest)
///     }
/// }
/// ```
public protocol RequestInterceptor: Sendable {
    /// Intercepts an HTTP request before it is sent and/or the response before it is returned.
    ///
    /// - Parameters:
    ///   - request: The outgoing `URLRequest`.
    ///   - next: A closure forwarding the (possibly mutated) request to the next interceptor
    ///           or to the transport layer. Call this to continue the chain.
    /// - Returns: The raw `(Data, HTTPURLResponse)` tuple from the downstream handler.
    /// - Throws: Any error from this interceptor or from calling `next`.
    // swiftformat:disable wrapArguments
    func intercept(_ request: URLRequest,
                   next: @Sendable (URLRequest) async throws -> (Data, HTTPURLResponse)) async throws
        -> (Data, HTTPURLResponse)
    // swiftformat:enable wrapArguments
}
