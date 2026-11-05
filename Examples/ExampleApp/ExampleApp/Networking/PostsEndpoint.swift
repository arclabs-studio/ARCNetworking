//
//  PostsEndpoint.swift
//  ExampleApp
//
//  Created by ARC Labs Studio on 08/01/2026.
//

import ARCNetworking
import Foundation
import HTTPTypes

/// Base URL for JSONPlaceholder API.
private let jsonPlaceholderBaseURL = URL.demoBase("https://jsonplaceholder.typicode.com")

// MARK: - Posts Endpoints

/// Endpoint to fetch all posts — uses type-safe ``HTTPFields`` headers.
///
/// Demonstrates the ``Endpoint/httpFields`` API: when `httpFields` is non-nil,
/// ``RequestBuilder`` routes through `HTTPTypesFoundation` instead of the legacy
/// `headers: [String: String]?` path.
struct PostsEndpoint: Endpoint {
    typealias Response = [Post]

    var baseURL: URL {
        jsonPlaceholderBaseURL
    }

    var path: String {
        "posts"
    }

    var method: HTTPMethod {
        .GET
    }

    var headers: [String: String]? {
        nil
    }

    var queryItems: [URLQueryItem]? {
        nil
    }

    var body: Data? {
        nil
    }

    var httpFields: HTTPFields? {
        var fields = HTTPFields()
        fields[.accept] = "application/json"
        fields[.cacheControl] = "no-cache"
        return fields
    }
}

/// Endpoint to fetch a single post by ID.
struct PostEndpoint: Endpoint {
    typealias Response = Post

    let postId: Int

    var baseURL: URL {
        jsonPlaceholderBaseURL
    }

    var path: String {
        "posts/\(postId)"
    }

    var method: HTTPMethod {
        .GET
    }

    var headers: [String: String]? {
        nil
    }

    var queryItems: [URLQueryItem]? {
        nil
    }

    var body: Data? {
        nil
    }
}

// MARK: - Streaming Endpoint

/// Streaming endpoint that receives line-delimited JSON from httpbin.
///
/// Demonstrates ``HTTPClientProtocol/stream(_:)``. The server delivers `count` JSON
/// objects one per line, which the stream yields as individual ``Data`` chunks —
/// the same pattern used for SSE (Server-Sent Events).
struct StreamLinesEndpoint: Endpoint {
    struct Response: Decodable {}

    let count: Int

    var baseURL: URL {
        URL.demoBase("https://httpbin.org")
    }

    var path: String {
        "stream/\(count)"
    }

    var method: HTTPMethod {
        .GET
    }

    var headers: [String: String]? {
        nil
    }

    var queryItems: [URLQueryItem]? {
        nil
    }

    var body: Data? {
        nil
    }
}

// MARK: - Demo Base URLs

extension URL {
    /// Parses a hard-coded demo base URL. A literal that does not parse is a programmer error.
    fileprivate static func demoBase(_ string: String) -> URL {
        guard let url = URL(string: string) else {
            preconditionFailure("Invalid demo base URL literal: \(string)")
        }
        return url
    }
}
