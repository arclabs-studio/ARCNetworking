//
//  ARCNetworkLogger.swift
//  ARCNetworking
//
//  Created by ARC Labs Studio on 24/10/25.
//

import Foundation
import os

/// A logger for network requests and responses using `os.Logger`.
///
/// `ARCNetworkLogger` provides structured logging for debugging network operations.
/// Logging is only active in DEBUG builds.
public enum ARCNetworkLogger {
    // MARK: Private Properties

    private static let logger = Logger(subsystem: "com.arclabs-studio.arcnetworking", category: "HTTP")

    // MARK: Public Functions

    /// Logs an outgoing HTTP request.
    ///
    /// - Parameter request: The URL request being sent.
    public static func log(request: URLRequest) {
        #if DEBUG
        let method = request.httpMethod ?? "UNKNOWN"
        let url = request.url?.absoluteString ?? "NO URL"

        logger.debug("➡️ Request: \(method) \(url)")

        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            logger.debug("📦 Headers: \(headers.description)")
        }

        if let body = request.httpBody,
           let bodyString = String(data: body, encoding: .utf8),
           !bodyString.isEmpty
        {
            logger.debug("📨 Body: \(bodyString)")
        }
        #endif
    }

    /// Logs an incoming HTTP response.
    ///
    /// - Parameters:
    ///   - response: The URL response received.
    ///   - data: The response data.
    public static func log(response: URLResponse?, data: Data?) {
        #if DEBUG
        guard let httpResponse = response as? HTTPURLResponse else {
            logger.warning("❌ Invalid HTTPURLResponse")
            return
        }

        let url = httpResponse.url?.absoluteString ?? "NO URL"
        logger.debug("⬅️ Response: \(httpResponse.statusCode) \(url)")

        if let data,
           let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
           let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
           let jsonString = String(data: prettyData, encoding: .utf8)
        {
            logger.debug("📦 Response JSON: \(jsonString)")
        } else if let data,
                  let text = String(data: data, encoding: .utf8),
                  !text.isEmpty
        {
            logger.debug("📦 Response Text: \(text)")
        }
        #endif
    }

    /// Logs an error that occurred during a network operation.
    ///
    /// - Parameter error: The error to log.
    public static func log(error: Error) {
        #if DEBUG
        logger.error("❌ Error: \(error.localizedDescription, privacy: .public)")
        #endif
    }
}
