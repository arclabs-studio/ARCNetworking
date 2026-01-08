//
//  RequestBuilderProtocol.swift
//  ARCNetworking
//
//  Created by ARC Labs Studio on 24/10/25.
//

import Foundation

/// A protocol that defines URL request building capabilities.
///
/// Conform to this protocol to create custom request builders that transform
/// endpoints into `URLRequest` objects.
public protocol RequestBuilderProtocol: Sendable {
    /// Builds a `URLRequest` from the given endpoint.
    ///
    /// - Parameter endpoint: The endpoint to transform into a request.
    /// - Returns: A configured `URLRequest` ready for execution.
    /// - Throws: `HTTPError.invalidURL` if the URL cannot be constructed.
    func buildRequest(from endpoint: any Endpoint) throws -> URLRequest
}
