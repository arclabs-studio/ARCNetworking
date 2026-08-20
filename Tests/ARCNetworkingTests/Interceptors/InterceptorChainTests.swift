//
//  InterceptorChainTests.swift
//  ARCNetworking
//
//  Created by ARC Labs Studio on 11/03/26.
//

import Foundation
import Testing
@testable import ARCNetworking

// MARK: - Spy Interceptor

private final class SpyInterceptor: RequestInterceptor, @unchecked Sendable {
    let name: String
    private(set) var callOrder: [String] = []
    private let sharedLog: SharedLog

    init(name: String, sharedLog: SharedLog) {
        self.name = name
        self.sharedLog = sharedLog
    }

    // swiftformat:disable wrapArguments
    func intercept(_ request: URLRequest,
                   next: @Sendable (URLRequest) async throws -> (Data, HTTPURLResponse)) async throws
    -> (Data, HTTPURLResponse) {
        // swiftformat:enable wrapArguments
        sharedLog.append(name)
        return try await next(request)
    }
}

private final class SharedLog: @unchecked Sendable {
    private var entries: [String] = []
    private let lock = NSLock()

    func append(_ name: String) {
        lock.withLock { entries.append(name) }
    }

    var all: [String] {
        lock.withLock { entries }
    }
}

// MARK: - Throwing Interceptor

private struct ThrowingInterceptor: RequestInterceptor {
    let error: Error

    // swiftformat:disable wrapArguments
    func intercept(_: URLRequest,
                   next _: @Sendable (URLRequest) async throws -> (Data, HTTPURLResponse)) async throws
    -> (Data, HTTPURLResponse) {
        // swiftformat:enable wrapArguments
        throw error
    }
}

// MARK: - Mutating Interceptor

private struct HeaderMutatingInterceptor: RequestInterceptor {
    let header: String
    let value: String

    // swiftformat:disable wrapArguments
    func intercept(_ request: URLRequest,
                   next: @Sendable (URLRequest) async throws -> (Data, HTTPURLResponse)) async throws
    -> (Data, HTTPURLResponse) {
        // swiftformat:enable wrapArguments
        var mutableRequest = request
        mutableRequest.setValue(value, forHTTPHeaderField: header)
        return try await next(mutableRequest)
    }
}

// MARK: - Tests

@Suite("InterceptorChain", .serialized) struct InterceptorChainTests {
    @Test("Interceptors are called in declaration order") func interceptorsAreCalledInDeclarationOrder() async throws {
        defer { unregisterHandler() }
        registerSuccessHandler()

        let log = SharedLog()
        let spy1 = SpyInterceptor(name: "first", sharedLog: log)
        let spy2 = SpyInterceptor(name: "second", sharedLog: log)
        let spy3 = SpyInterceptor(name: "third", sharedLog: log)

        let sut = makeSUT(interceptors: [spy1, spy2, spy3])
        _ = try await sut.execute(MockChainEndpoint())

        #expect(log.all == ["first", "second", "third"])
    }

    @Test("Chain short-circuits when interceptor throws") func chainShortCircuitsWhenInterceptorThrows() async {
        defer { unregisterHandler() }
        registerSuccessHandler()

        let log = SharedLog()
        let spy = SpyInterceptor(name: "before", sharedLog: log)
        let throwing = ThrowingInterceptor(error: HTTPError.requestFailed(statusCode: 503, data: Data()))
        let afterSpy = SpyInterceptor(name: "after", sharedLog: log)

        let sut = makeSUT(interceptors: [spy, throwing, afterSpy])

        do {
            _ = try await sut.execute(MockChainEndpoint())
            Issue.record("Expected an error to be thrown")
        } catch let error as HTTPError {
            if case .requestFailed(statusCode: 503, data: _) = error {
                #expect(log.all == ["before"])
            } else {
                Issue.record("Unexpected error: \(error)")
            }
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }

    @Test("Interceptor can mutate request before forwarding") func interceptorCanMutateRequest() async throws {
        defer { unregisterHandler() }

        var receivedHeader: String?
        MockURLProtocol.register({ request in
            receivedHeader = request.value(forHTTPHeaderField: "X-Mutated")
            // swiftlint:disable:next force_unwrapping
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            let data = try JSONEncoder().encode(MockChainResponse(status: "ok"))
            return (response, data)
        }, for: "chain-tests.arcnetworking")

        let mutator = HeaderMutatingInterceptor(header: "X-Mutated", value: "yes")
        let sut = makeSUT(interceptors: [mutator])
        _ = try await sut.execute(MockChainEndpoint())

        #expect(receivedHeader == "yes")
    }
}

// MARK: - Private Helpers

extension InterceptorChainTests {
    private func makeSUT(interceptors: [any RequestInterceptor]) -> HTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: configuration)
        return HTTPClient(session: session, builder: RequestBuilder(), interceptors: interceptors)
    }

    private func registerSuccessHandler() {
        MockURLProtocol.register({ request in
            // swiftlint:disable:next force_unwrapping
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            let data = try JSONEncoder().encode(MockChainResponse(status: "ok"))
            return (response, data)
        }, for: "chain-tests.arcnetworking")
    }

    private func unregisterHandler() {
        MockURLProtocol.unregister(host: "chain-tests.arcnetworking")
    }
}

// MARK: - Test Fixtures

private struct MockChainResponse: Codable, Equatable {
    let status: String
}

private struct MockChainEndpoint: Endpoint {
    typealias Response = MockChainResponse

    var baseURL: URL {
        URL(string: "https://chain-tests.arcnetworking")!
    }

    var path: String {
        "test"
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
