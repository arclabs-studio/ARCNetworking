//
//  HTTPClient.swift
//  ARCNetworking
//
//  Created by ARC Labs Studio on 24/10/25.
//

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

        #if DEBUG
        ARCNetworkLogger.log(request: request)
        #endif

        let (data, response) = try await session.data(for: request)

        #if DEBUG
        ARCNetworkLogger.log(response: response, data: data)
        #endif

        guard let httpResponse = response as? HTTPURLResponse else {
            throw HTTPError.unknown(NSError(domain: "Invalid response", code: 0))
        }

        guard HTTPStatusCode.successRange.contains(httpResponse.statusCode) else {
            throw HTTPError.requestFailed(httpResponse.statusCode)
        }

        do {
            return try decoder.decode(T.Response.self, from: data)
        } catch {
            #if DEBUG
            ARCNetworkLogger.log(error: error)
            #endif
            throw HTTPError.decodingFailed(error)
        }
    }
}
