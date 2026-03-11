//
//  LoggingInterceptor.swift
//  ARCNetworking
//
//  Created by ARC Labs Studio on 11/03/26.
//

import ARCLogger
import Foundation

/// An interceptor that logs outgoing requests and incoming responses.
///
/// Logging is gated by `#if DEBUG` to avoid leaking sensitive data in production builds.
/// `HTTPClient` uses this as the default interceptor to preserve v1.0 logging behaviour.
public final class LoggingInterceptor: RequestInterceptor, @unchecked Sendable {
    // MARK: Private Properties

    private let logger = ARCLogger(subsystem: "com.arclabs-studio.arcnetworking", category: "HTTP")

    // MARK: Initialization

    /// Creates a logging interceptor.
    public init() {}

    // MARK: RequestInterceptor

    // swiftformat:disable wrapArguments
    public func intercept(_ request: URLRequest,
                          next: @Sendable (URLRequest) async throws -> (Data, HTTPURLResponse)) async throws
    -> (Data, HTTPURLResponse) {
        // swiftformat:enable wrapArguments
        #if DEBUG
        logRequest(request)
        #endif

        let (data, response) = try await next(request)

        #if DEBUG
        logResponse(response, data: data)
        #endif

        return (data, response)
    }

    // MARK: Private Functions

    private func logRequest(_ request: URLRequest) {
        let method = request.httpMethod ?? "UNKNOWN"
        let url = request.url?.absoluteString ?? "NO URL"

        logger.debug("Request: \(method) \(url)")

        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            logger.debug("Headers: \(headers.description)")
        }

        if let body = request.httpBody,
           let bodyString = String(data: body, encoding: .utf8),
           !bodyString.isEmpty {
            logger.debug("Body: \(bodyString)")
        }
    }

    private func logResponse(_ response: HTTPURLResponse, data: Data) {
        let url = response.url?.absoluteString ?? "NO URL"
        logger.debug("Response: \(response.statusCode) \(url)")

        if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
           let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
           let jsonString = String(data: prettyData, encoding: .utf8) {
            logger.debug("Response JSON: \(jsonString)")
        } else if let text = String(data: data, encoding: .utf8), !text.isEmpty {
            logger.debug("Response Text: \(text)")
        }
    }
}
