//
//  NetworkClientFactory.swift
//  ExampleApp
//
//  Created by ARC Labs Studio on 11/03/26.
//

import ARCNetworking
import Foundation

/// Demonstrates how to configure an ``HTTPClient`` with a composable interceptor pipeline.
///
/// The pipeline applies interceptors in declaration order:
/// 1. ``AuthenticationInterceptor`` — injects a Bearer token before the request is sent.
/// 2. ``RetryInterceptor`` — retries up to 2 times on HTTP 5xx with exponential backoff.
/// 3. ``LoggingInterceptor`` — logs requests and responses in debug builds.
enum NetworkClientFactory {
    /// Creates a pre-configured ``HTTPClient`` with auth, retry, and logging interceptors.
    static func makeClient() -> HTTPClient {
        HTTPClient(interceptors: [AuthenticationInterceptor { "demo-bearer-token" },
                                  RetryInterceptor(maxRetries: 2),
                                  LoggingInterceptor()])
    }
}
