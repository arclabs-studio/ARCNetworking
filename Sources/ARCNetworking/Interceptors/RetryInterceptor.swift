//
//  RetryInterceptor.swift
//  ARCNetworking
//
//  Created by ARC Labs Studio on 11/03/26.
//

import Foundation

/// An interceptor that retries requests on server-side failures (HTTP 5xx).
///
/// Uses exponential backoff: delay doubles with each attempt (`baseDelay × 2^attempt`).
/// Transport errors (e.g. `URLError`) and client errors (4xx) are **not** retried.
///
/// ## Example
///
/// ```swift
/// let retry = RetryInterceptor(maxRetries: 3, baseDelay: .seconds(1))
/// let client = HTTPClient(interceptors: [retry])
/// ```
public struct RetryInterceptor: RequestInterceptor {
    // MARK: Private Properties

    private let maxRetries: Int
    private let baseDelay: Duration
    private let sleep: @Sendable (Duration) async throws -> Void

    // MARK: Initialization

    /// Creates a retry interceptor.
    ///
    /// - Parameters:
    ///   - maxRetries: Maximum number of retry attempts after the initial request. Defaults to `3`.
    ///   - baseDelay: Base delay for the first retry. Doubles with each attempt. Defaults to `.seconds(1)`.
    ///   - sleep: Injectable sleep function for testability. Defaults to `Task.sleep(for:)`.
    public init(maxRetries: Int = 3,
                baseDelay: Duration = .seconds(1),
                sleep: @Sendable @escaping (Duration) async throws -> Void = { try await Task.sleep(for: $0) }) {
        self.maxRetries = maxRetries
        self.baseDelay = baseDelay
        self.sleep = sleep
    }

    // MARK: RequestInterceptor

    /// Executes the request, retrying on HTTP 5xx with exponential backoff.
    /// Non-retryable responses (2xx, 3xx, 4xx) and transport errors are returned or thrown immediately.
    ///
    /// - SeeAlso: ``RequestInterceptor/intercept(_:next:)``
    // swiftformat:disable wrapArguments
    public func intercept(_ request: URLRequest,
                          next: @Sendable (URLRequest) async throws -> (Data, HTTPURLResponse)) async throws
    -> (Data, HTTPURLResponse) {
        // swiftformat:enable wrapArguments
        var lastError: Error = HTTPError.unknown(NSError(domain: "RetryInterceptor", code: 0))

        for attempt in 0 ..< (maxRetries + 1) {
            if attempt > 0 {
                // Exponential backoff: baseDelay × 2^attempt
                try await sleep(baseDelay * (1 << attempt))
            }

            // Transport errors (URLError etc.) are not retried — propagate immediately.
            let (data, response) = try await next(request)

            if response.statusCode >= 500 {
                lastError = HTTPError.requestFailed(response.statusCode)
                if attempt < maxRetries { continue }
            } else {
                // 2xx, 3xx, 4xx — return immediately without retry.
                return (data, response)
            }
        }

        throw lastError
    }
}
