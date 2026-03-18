//
//  RetryInterceptorTests.swift
//  ARCNetworking
//
//  Created by ARC Labs Studio on 11/03/26.
//

import Foundation
import Testing
@testable import ARCNetworking

// MARK: - Tests

@Suite("RetryInterceptor", .serialized) struct RetryInterceptorTests {
    /// No-op sleep to keep tests instant
    private let noSleep: @Sendable (Duration) async throws -> Void = { _ in }

    @Test("Does not retry on 2xx") func doesNotRetryOn2xx() async throws {
        let counter = Box(0)
        let next: @Sendable (URLRequest) async throws -> (Data, HTTPURLResponse) = { req in
            counter.value += 1
            // swiftlint:disable:next force_unwrapping
            let response = HTTPURLResponse(url: req.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (Data(), response)
        }

        let sut = RetryInterceptor(maxRetries: 3, sleep: noSleep)
        let request = try URLRequest(url: #require(URL(string: "https://example.com")))
        _ = try await sut.intercept(request, next: next)

        #expect(counter.value == 1)
    }

    @Test("Does not retry on 4xx") func doesNotRetryOn4xx() async throws {
        let counter = Box(0)
        let next: @Sendable (URLRequest) async throws -> (Data, HTTPURLResponse) = { req in
            counter.value += 1
            // swiftlint:disable:next force_unwrapping
            let response = HTTPURLResponse(url: req.url!, statusCode: 404, httpVersion: nil, headerFields: nil)!
            return (Data(), response)
        }

        let sut = RetryInterceptor(maxRetries: 3, sleep: noSleep)
        let request = try URLRequest(url: #require(URL(string: "https://example.com")))
        _ = try await sut.intercept(request, next: next)

        #expect(counter.value == 1)
    }

    @Test("Retries up to maxRetries on 5xx then propagates error") func retriesUpToMaxRetriesOn5xx() async throws {
        let counter = Box(0)
        let maxRetries = 3
        let next: @Sendable (URLRequest) async throws -> (Data, HTTPURLResponse) = { req in
            counter.value += 1
            // swiftlint:disable:next force_unwrapping
            let response = HTTPURLResponse(url: req.url!, statusCode: 503, httpVersion: nil, headerFields: nil)!
            return (Data(), response)
        }

        let sut = RetryInterceptor(maxRetries: maxRetries, sleep: noSleep)
        let request = try URLRequest(url: #require(URL(string: "https://example.com")))

        do {
            _ = try await sut.intercept(request, next: next)
            Issue.record("Expected HTTPError.requestFailed to be thrown")
        } catch let error as HTTPError {
            if case let .requestFailed(code, _) = error {
                #expect(code == 503)
                // Initial attempt + maxRetries retries
                #expect(counter.value == maxRetries + 1)
            } else {
                Issue.record("Unexpected error: \(error)")
            }
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }

    @Test("Returns success if transient 5xx resolves before maxRetries")
    func returnsSuccessIfTransient5xxResolvesBeforeMaxRetries() async throws {
        let counter = Box(0)
        let next: @Sendable (URLRequest) async throws -> (Data, HTTPURLResponse) = { req in
            counter.value += 1
            let statusCode = counter.value < 3 ? 503 : 200
            // swiftlint:disable:next force_unwrapping
            let response = HTTPURLResponse(url: req.url!, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
            return (Data(), response)
        }

        let sut = RetryInterceptor(maxRetries: 5, sleep: noSleep)
        let request = try URLRequest(url: #require(URL(string: "https://example.com")))
        let (_, response) = try await sut.intercept(request, next: next)

        #expect(response.statusCode == 200)
        #expect(counter.value == 3) // 2 failures + 1 success
    }
}
