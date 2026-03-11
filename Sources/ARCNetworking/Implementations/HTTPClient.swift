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
/// Interceptors are composed into a chain at initialisation time and executed in declaration
/// order. The default chain contains ``LoggingInterceptor``, preserving v1.0 behaviour.
///
/// ## Example
///
/// ```swift
/// // Default — identical behaviour to v1.0
/// let client = HTTPClient()
///
/// // With Firebase auth injection
/// let client = HTTPClient(interceptors: [
///     AuthenticationInterceptor { try await Auth.auth().currentUser!.getIDToken() },
///     RetryInterceptor(maxRetries: 2),
///     LoggingInterceptor()
/// ])
/// ```
public final class HTTPClient: HTTPClientProtocol {
    // MARK: Private Properties

    private let session: URLSession
    private let builder: RequestBuilderProtocol
    private let decoder: JSONDecoder
    private let chain: @Sendable (URLRequest) async throws -> (Data, HTTPURLResponse)

    // MARK: Initialization

    /// Creates an HTTP client with the specified dependencies.
    ///
    /// - Parameters:
    ///   - session: The URL session to use for requests. Defaults to `.shared`.
    ///   - builder: The request builder to transform endpoints. Defaults to `RequestBuilder()`.
    ///   - decoder: The JSON decoder for response parsing. Defaults to `JSONDecoder()`.
    ///   - interceptors: Middleware applied to every request in declaration order.
    ///                   Defaults to `[LoggingInterceptor()]` for backwards compatibility.
    public init(session: URLSession = .shared,
                builder: RequestBuilderProtocol = RequestBuilder(),
                decoder: JSONDecoder = JSONDecoder(),
                interceptors: [any RequestInterceptor] = [LoggingInterceptor()]) {
        self.session = session
        self.builder = builder
        self.decoder = decoder

        // Base transport handler — sole point of URLSession usage.
        // TODO: Migrate to Swift unified HTTP client when available (swift-evolution vision)
        let base: @Sendable (URLRequest) async throws -> (Data, HTTPURLResponse) = { [session] req in
            let (data, response) = try await session.data(for: req)
            guard let http = response as? HTTPURLResponse else {
                throw HTTPError.unknown(NSError(domain: "Invalid response", code: 0))
            }
            return (data, http)
        }

        // Fold interceptors right-to-left so interceptors[0] executes first.
        chain = interceptors.reversed().reduce(base) { next, interceptor in
            let capturedNext = next
            return { @Sendable [interceptor] (req: URLRequest) in
                try await interceptor.intercept(req, next: capturedNext)
            }
        }
    }

    // MARK: Public Functions

    /// Streams an HTTP response as an `AsyncThrowingStream` of `Data` chunks.
    ///
    /// Uses `URLSession.bytes(for:)` and delivers one chunk per response line,
    /// making it ideal for SSE (Server-Sent Events) and other line-delimited formats.
    ///
    /// - Parameter endpoint: The endpoint defining the request parameters.
    /// - Returns: An `AsyncThrowingStream` delivering response data line by line.
    /// - Throws: `HTTPError.requestFailed` on non-2xx responses;
    ///           `HTTPError.unknown` if the response is not an `HTTPURLResponse`;
    ///           `CancellationError` if the consuming task is cancelled.
    public func stream(_ endpoint: some Endpoint) -> AsyncThrowingStream<Data, Error> {
        // Build the request synchronously so endpoint is not captured across concurrency boundaries.
        let requestResult = Result { try builder.buildRequest(from: endpoint) }
        return AsyncThrowingStream { continuation in
            Task { [session] in
                do {
                    let request = try requestResult.get()
                    let (bytes, response) = try await session.bytes(for: request)

                    guard let http = response as? HTTPURLResponse else {
                        continuation.finish(throwing: HTTPError.unknown(NSError(domain: "Invalid response", code: 0)))
                        return
                    }

                    guard HTTPStatusCode.successRange.contains(http.statusCode) else {
                        continuation.finish(throwing: HTTPError.requestFailed(http.statusCode))
                        return
                    }

                    for try await line in bytes.lines {
                        continuation.yield(Data(line.utf8))
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    public func execute<T: Endpoint>(_ endpoint: T) async throws -> T.Response {
        let request = try builder.buildRequest(from: endpoint)
        let (data, response) = try await chain(request)

        guard HTTPStatusCode.successRange.contains(response.statusCode) else {
            throw HTTPError.requestFailed(response.statusCode)
        }

        do {
            return try decoder.decode(T.Response.self, from: data)
        } catch {
            throw HTTPError.decodingFailed(error)
        }
    }
}
