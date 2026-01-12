//
//  PostsEndpoint.swift
//  ExampleApp
//
//  Created by ARC Labs Studio on 08/01/2026.
//

import ARCNetworking
import Foundation

/// Base URL for JSONPlaceholder API.
private let jsonPlaceholderBaseURL = URL(string: "https://jsonplaceholder.typicode.com")

/// Endpoint to fetch posts from JSONPlaceholder API.
struct PostsEndpoint: Endpoint {
    typealias Response = [Post]

    // swiftlint:disable:next force_unwrapping
    var baseURL: URL { jsonPlaceholderBaseURL! }
    var path: String { "posts" }
    var method: HTTPMethod { .GET }
    var headers: [String: String]? { nil }
    var queryItems: [URLQueryItem]? { nil }
    var body: Data? { nil }
}

/// Endpoint to fetch a single post by ID.
struct PostEndpoint: Endpoint {
    typealias Response = Post

    let postId: Int

    // swiftlint:disable:next force_unwrapping
    var baseURL: URL { jsonPlaceholderBaseURL! }
    var path: String { "posts/\(postId)" }
    var method: HTTPMethod { .GET }
    var headers: [String: String]? { nil }
    var queryItems: [URLQueryItem]? { nil }
    var body: Data? { nil }
}
