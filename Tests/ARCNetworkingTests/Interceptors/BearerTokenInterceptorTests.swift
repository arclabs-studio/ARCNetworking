//
//  BearerTokenInterceptorTests.swift
//  ARCNetworking
//
//  Created by ARC Labs Studio on 18/03/26.
//

import Foundation
import Testing
@testable import ARCNetworking

// MARK: - Tests

@Suite("BearerTokenInterceptor", .serialized) struct BearerTokenInterceptorTests {
    @Test("Injects Authorization Bearer header") func injectsAuthorizationBearerHeader() async throws {
        let capturedRequest = Box<URLRequest?>(nil)
        let next: @Sendable (URLRequest) async throws -> (Data, HTTPURLResponse) = { req in
            capturedRequest.value = req
            return makeBearerOKResponse(for: req)
        }

        let sut = BearerTokenInterceptor { "sync-token-xyz" }
        let request = try URLRequest(url: #require(URL(string: "https://example.com")))
        _ = try await sut.intercept(request, next: next)

        #expect(capturedRequest.value?.value(forHTTPHeaderField: "Authorization") == "Bearer sync-token-xyz")
    }

    @Test("Propagates tokenProvider errors and short-circuits chain") func propagatesTokenProviderErrors() async throws {
        let nextCalled = Box(false)
        let next: @Sendable (URLRequest) async throws -> (Data, HTTPURLResponse) = { req in
            nextCalled.value = true
            Issue.record("next should not be called when tokenProvider throws")
            return makeBearerOKResponse(for: req)
        }

        struct TokenError: Error {}
        let sut = BearerTokenInterceptor { throw TokenError() }
        let request = try URLRequest(url: #require(URL(string: "https://example.com")))

        do {
            _ = try await sut.intercept(request, next: next)
            Issue.record("Expected error to be thrown")
        } catch is TokenError {
            #expect(!nextCalled.value)
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }

    @Test("Overwrites existing Authorization header") func overwritesExistingAuthorizationHeader() async throws {
        let capturedRequest = Box<URLRequest?>(nil)
        let next: @Sendable (URLRequest) async throws -> (Data, HTTPURLResponse) = { req in
            capturedRequest.value = req
            return makeBearerOKResponse(for: req)
        }

        let sut = BearerTokenInterceptor { "new-sync-token" }
        var request = try URLRequest(url: #require(URL(string: "https://example.com")))
        request.setValue("Bearer old-token", forHTTPHeaderField: "Authorization")

        _ = try await sut.intercept(request, next: next)

        #expect(capturedRequest.value?.value(forHTTPHeaderField: "Authorization") == "Bearer new-sync-token")
    }
}

// MARK: - Private Helpers

private func makeBearerOKResponse(for request: URLRequest) -> (Data, HTTPURLResponse) {
    // swiftlint:disable:next force_unwrapping
    let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
    return (Data(), response)
}
