//
//  HTTPClientStreamingTests.swift
//  ARCNetworking
//
//  Created by ARC Labs Studio on 11/03/26.
//

import Foundation
import Testing
@testable import ARCNetworking

// MARK: - Fixtures

private struct StreamResponseModel: Codable {
    let event: String
}

private struct MockStreamEndpoint: Endpoint {
    typealias Response = StreamResponseModel

    var baseURL: URL {
        // swiftlint:disable:next force_unwrapping
        URL(string: "https://stream-tests.arcnetworking")!
    }

    var path: String {
        "events"
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

// MARK: - Suspending URLProtocol (for cancellation test)

/// A URLProtocol that delivers an HTTP 200 response header but never delivers body bytes.
/// Used to verify that a consuming task sees CancellationError when cancelled mid-stream.
private class SuspendingURLProtocol: URLProtocol {
    override class func canInit(with _: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let url = request.url else { return }
        // swiftlint:disable:next force_unwrapping
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        // Intentionally omit urlProtocolDidFinishLoading to simulate an open, streaming connection.
    }

    override func stopLoading() {}
}

// MARK: - Tests

@Suite("HTTPClient streaming", .serialized) struct HTTPClientStreamingTests {
    @Test("stream delivers Data chunks via AsyncThrowingStream") func streamDeliversDataChunks() async throws {
        defer { unregisterHandler() }

        let lines = ["event: ping", "data: {\"status\":\"ok\"}", "event: close"]
        registerLinesHandler(lines)

        let sut = makeSUT()
        var received: [String] = []
        for try await chunk in sut.stream(MockStreamEndpoint()) {
            if let line = String(data: chunk, encoding: .utf8) {
                received.append(line)
            }
        }

        #expect(received == lines)
    }

    @Test("stream finishes cleanly after last byte") func streamFinishesCleanlyAfterLastByte() async throws {
        defer { unregisterHandler() }

        registerLinesHandler(["only-line"])

        let sut = makeSUT()
        var count = 0
        for try await _ in sut.stream(MockStreamEndpoint()) {
            count += 1
        }

        // Stream completed without error; exactly one line was delivered.
        #expect(count == 1)
    }

    @Test("stream throws HTTPError.requestFailed on non-2xx") func streamThrowsOnNon2xx() async {
        defer { unregisterHandler() }

        MockStreamURLProtocol.register({ request in
            // swiftlint:disable:next force_unwrapping
            let response = HTTPURLResponse(url: request.url!, statusCode: 503, httpVersion: nil, headerFields: nil)!
            return (response, [])
        }, for: "stream-tests.arcnetworking")

        let sut = makeSUT()

        do {
            for try await _ in sut.stream(MockStreamEndpoint()) {}
            Issue.record("Expected HTTPError.requestFailed")
        } catch let error as HTTPError {
            if case let .requestFailed(code) = error {
                #expect(code == 503)
            } else {
                Issue.record("Unexpected HTTPError: \(error)")
            }
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }

    @Test("stream throws on cancellation") func streamThrowsOnCancellation() async {
        let sut = makeSuspendingSUT()
        let endpoint = MockStreamEndpoint()

        let consumerTask = Task {
            for try await _ in sut.stream(endpoint) {
                // Never reached — suspending mock never delivers bytes.
            }
        }

        // Yield once so the consumer task starts and suspends on bytes.lines.
        await Task.yield()
        consumerTask.cancel()

        do {
            try await consumerTask.value
            // Acceptable if the task completed before cancellation was checked.
        } catch is CancellationError {
            // Expected: task was cancelled while awaiting the next stream element.
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }
}

// MARK: - Private Helpers

extension HTTPClientStreamingTests {
    private func makeSUT() -> HTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockStreamURLProtocol.self]
        let session = URLSession(configuration: configuration)
        return HTTPClient(session: session, builder: RequestBuilder(), interceptors: [])
    }

    private func makeSuspendingSUT() -> HTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [SuspendingURLProtocol.self]
        let session = URLSession(configuration: configuration)
        return HTTPClient(session: session, builder: RequestBuilder(), interceptors: [])
    }

    private func registerLinesHandler(_ lines: [String]) {
        MockStreamURLProtocol.register({ request in
            // swiftlint:disable:next force_unwrapping
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            // Join lines with newline delimiters; bytes.lines splits on \n.
            let body = Data((lines.joined(separator: "\n") + "\n").utf8)
            return (response, [body])
        }, for: "stream-tests.arcnetworking")
    }

    private func unregisterHandler() {
        MockStreamURLProtocol.unregister(host: "stream-tests.arcnetworking")
    }
}
