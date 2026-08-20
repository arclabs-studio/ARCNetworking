//
//  HTTPClientProtocol.swift
//  ARCNetworking
//
//  Created by ARC Labs Studio on 24/10/25.
//

import Foundation

/// A protocol that defines HTTP client capabilities.
///
/// Conform to this protocol to create custom HTTP clients that can execute
/// endpoint requests and return decoded responses.
public protocol HTTPClientProtocol: Sendable {
    /// Executes an HTTP request for the given endpoint and returns the decoded response.
    ///
    /// - Parameter endpoint: The endpoint defining the request parameters.
    /// - Returns: The decoded response of the endpoint's associated `Response` type.
    /// - Throws: `HTTPError` if the request fails or the response cannot be decoded.
    ///
    /// <!-- TODO: Migrate to typed throws(HTTPError) once SE-0413 adoption is confirmed safe.
    ///      Blocker: protocol change is source-breaking for existing conformers.
    ///      When ready: func execute<T: Endpoint>(_ endpoint: T) async throws(HTTPError) -> T.Response
    ///      Note: URLError from transport must be wrapped in HTTPError.unknown before landing.
    ///      Affected test: HTTPClientTests.executePropagatesTransportError -->
    func execute<T: Endpoint>(_ endpoint: T) async throws -> T.Response

    /// Streams an HTTP response as an `AsyncThrowingStream` of `Data` chunks.
    ///
    /// Suitable for SSE (Server-Sent Events) or any line-delimited streaming response.
    /// Each chunk corresponds to one line of response data.
    ///
    /// - Parameter endpoint: The endpoint defining the request parameters.
    /// - Returns: An `AsyncThrowingStream` delivering response data line by line.
    func stream(_ endpoint: some Endpoint) -> AsyncThrowingStream<Data, Error>
}

extension HTTPClientProtocol {
    /// Default implementation — existing conformers (`MockHTTPClient`, etc.)
    /// get this for free; no changes required in test files.
    public func stream(_: some Endpoint) -> AsyncThrowingStream<Data, Error> {
        AsyncThrowingStream { continuation in
            let error = NSError(domain: "HTTPClientProtocol",
                                code: -1,
                                userInfo: [NSLocalizedDescriptionKey: "stream(_:) not implemented by this conformer"])
            continuation.finish(throwing: HTTPError.unknown(error))
        }
    }
}
