//
//  RequestBuilder.swift
//  ARCNetworking
//
//  Created by ARC Labs Studio on 24/10/25.
//

import Foundation
import HTTPTypes
import HTTPTypesFoundation

/// A concrete request builder that transforms endpoints into `URLRequest` objects.
///
/// `RequestBuilder` is the default implementation of ``RequestBuilderProtocol``.
///
/// When the endpoint provides ``Endpoint/httpFields``, the builder applies type-safe headers
/// via `HTTPTypes`. Otherwise, it falls back to the legacy `headers: [String: String]?` path.
public struct RequestBuilder: RequestBuilderProtocol {
    // MARK: Initialization

    /// Creates a new request builder.
    public init() {}

    // MARK: Public Functions

    /// Builds a `URLRequest` from the given endpoint.
    ///
    /// Resolves the full URL by appending `endpoint.path` to `endpoint.baseURL`,
    /// applies query items, then sets headers via `HTTPTypes` if available,
    /// or falls back to the legacy `[String: String]` headers path.
    ///
    /// - Parameter endpoint: The endpoint describing the request configuration.
    /// - Returns: A fully configured `URLRequest`.
    /// - Throws: ``HTTPError/invalidURL`` if the resolved URL is malformed.
    public func buildRequest(from endpoint: any Endpoint) throws -> URLRequest {
        guard var components = URLComponents(url: endpoint.baseURL.appendingPathComponent(endpoint.path),
                                             resolvingAgainstBaseURL: false) else {
            throw HTTPError.invalidURL
        }

        components.queryItems = endpoint.queryItems

        guard let url = components.url else {
            throw HTTPError.invalidURL
        }

        if let httpFields = endpoint.httpFields {
            return buildRequestUsingHTTPTypes(url: url, endpoint: endpoint, fields: httpFields)
        }

        return buildRequestLegacy(url: url, endpoint: endpoint)
    }
}

// MARK: - Private

extension RequestBuilder {
    private func buildRequestUsingHTTPTypes(url: URL,
                                            endpoint: any Endpoint,
                                            fields: HTTPFields) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body
        // Apply typed HTTP fields from HTTPTypes to the URLRequest.
        // HTTPFields provides type-safe header access; HTTPTypesFoundation bridges to URLRequest.
        for field in fields {
            request.addValue(field.value, forHTTPHeaderField: field.name.rawName)
        }
        return request
    }

    private func buildRequestLegacy(url: URL, endpoint: any Endpoint) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body
        endpoint.headers?.forEach { request.addValue($1, forHTTPHeaderField: $0) }
        return request
    }
}
