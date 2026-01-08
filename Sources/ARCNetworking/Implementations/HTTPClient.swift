//
//  HTTPClient.swift
//  ARCNetworking
//
//  Created by ARC Labs Studio on 24/10/25.
//

import ARCLogger
import Foundation

/// A concrete HTTP client that executes network requests using `URLSession`.
///
/// `HTTPClient` is the default implementation of ``HTTPClientProtocol`` that handles
/// request building, execution, and response decoding.
///
/// ## Example
///
/// ```swift
/// let client = HTTPClient()
/// let response = try await client.execute(myEndpoint)
/// ```
public final class HTTPClient: HTTPClientProtocol {
    // MARK: Private Properties

    private let session: URLSession
    private let builder: RequestBuilderProtocol
    private let decoder: JSONDecoder
    private let logger = ARCLogger(subsystem: "com.arclabs-studio.arcnetworking", category: "HTTP")

    // MARK: Initialization

    /// Creates an HTTP client with the specified dependencies.
    ///
    /// - Parameters:
    ///   - session: The URL session to use for requests. Defaults to `.shared`.
    ///   - builder: The request builder to transform endpoints. Defaults to `RequestBuilder()`.
    ///   - decoder: The JSON decoder for response parsing. Defaults to `JSONDecoder()`.
    public init(
        session: URLSession = .shared,
        builder: RequestBuilderProtocol = RequestBuilder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.session = session
        self.builder = builder
        self.decoder = decoder
    }

    // MARK: Public Functions

    public func execute<T>(_ endpoint: T) async throws -> T.Response where T: Endpoint {
        let request = try builder.buildRequest(from: endpoint)

        logRequest(request)

        let (data, response) = try await session.data(for: request)

        logResponse(response, data: data)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw HTTPError.unknown(NSError(domain: "Invalid response", code: 0))
        }

        guard HTTPStatusCode.successRange.contains(httpResponse.statusCode) else {
            throw HTTPError.requestFailed(httpResponse.statusCode)
        }

        do {
            return try decoder.decode(T.Response.self, from: data)
        } catch {
            logger.error("Decoding failed", metadata: ["error": .public(error.localizedDescription)])
            throw HTTPError.decodingFailed(error)
        }
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
           !bodyString.isEmpty
        {
            logger.debug("Body: \(bodyString)")
        }
    }

    private func logResponse(_ response: URLResponse?, data: Data?) {
        guard let httpResponse = response as? HTTPURLResponse else {
            logger.warning("Invalid HTTPURLResponse")
            return
        }

        let url = httpResponse.url?.absoluteString ?? "NO URL"
        logger.debug("Response: \(httpResponse.statusCode) \(url)")

        if let data,
           let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
           let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
           let jsonString = String(data: prettyData, encoding: .utf8)
        {
            logger.debug("Response JSON: \(jsonString)")
        } else if let data,
                  let text = String(data: data, encoding: .utf8),
                  !text.isEmpty
        {
            logger.debug("Response Text: \(text)")
        }
    }
}
