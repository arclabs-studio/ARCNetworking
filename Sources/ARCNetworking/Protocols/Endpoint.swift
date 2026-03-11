//
//  Endpoint.swift
//  ARCNetworking
//
//  Created by ARC Labs Studio on 24/10/25.
//

import Foundation
import HTTPTypes

/// A protocol that defines the components of an HTTP endpoint.
///
/// Conform to this protocol to define API endpoints with their associated
/// response types, enabling type-safe network requests.
///
/// ## Example
///
/// ```swift
/// struct GetUserEndpoint: Endpoint {
///     typealias Response = User
///
///     var baseURL: URL { URL(string: "https://api.example.com")! }
///     var path: String { "users/\(userId)" }
///     var method: HTTPMethod { .GET }
///     var headers: [String: String]? { nil }
///     var queryItems: [URLQueryItem]? { nil }
///     var body: Data? { nil }
///
///     let userId: String
/// }
/// ```
public protocol Endpoint {
    /// The response type that will be decoded from the endpoint's response data.
    associatedtype Response: Decodable

    /// The base URL for the endpoint.
    var baseURL: URL { get }

    /// The path component to append to the base URL.
    var path: String { get }

    /// The HTTP method for the request.
    var method: HTTPMethod { get }

    /// Optional HTTP headers to include in the request.
    ///
    /// - Note: Prefer ``httpFields`` for typed header access when adopting `swift-http-types`.
    ///   `headers` remains supported for backwards compatibility.
    var headers: [String: String]? { get }

    /// Optional query items to append to the URL.
    var queryItems: [URLQueryItem]? { get }

    /// Optional body data for the request.
    var body: Data? { get }

    /// Optional HTTP fields using the type-safe `HTTPTypes` package.
    ///
    /// When non-nil, `RequestBuilder` will use `HTTPTypes` to construct the request,
    /// enabling type-safe header access and alignment with the Swift community's unified HTTP model.
    ///
    /// - Note: This property is a protocol requirement (not just an extension default) so that
    ///   overrides are dispatched correctly through existentials and generics.
    ///   Existing conformers that do not implement this property use the extension default (`nil`),
    ///   which preserves backwards compatibility.
    var httpFields: HTTPFields? { get }
}

extension Endpoint {
    /// Default implementation returns `nil`, preserving backwards compatibility.
    /// Existing conformers require no changes.
    public var httpFields: HTTPFields? {
        nil
    }
}
