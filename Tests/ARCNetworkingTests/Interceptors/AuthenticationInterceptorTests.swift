//
//  AuthenticationInterceptorTests.swift
//  ARCNetworking
//
//  Created by ARC Labs Studio on 11/03/26.
//

import Foundation
import Testing
@testable import ARCNetworking

// MARK: - Tests

@Suite("AuthenticationInterceptor", .serialized) struct AuthenticationInterceptorTests {
    @Test("Injects Authorization Bearer header") func injectsAuthorizationBearerHeader() async throws {
        let capturedRequest = Box<URLRequest?>(nil)
        let next: @Sendable (URLRequest) async throws -> (Data, HTTPURLResponse) = { req in
            capturedRequest.value = req
            return makeOKResponse(for: req)
        }

        let sut = AuthenticationInterceptor { "test-token-abc" }
        let request = try URLRequest(url: #require(URL(string: "https://example.com")))
        _ = try await sut.intercept(request, next: next)

        #expect(capturedRequest.value?.value(forHTTPHeaderField: "Authorization") == "Bearer test-token-abc")
    }

    @Test("Propagates tokenProvider errors") func propagatesTokenProviderErrors() async throws {
        let nextCalled = Box(false)
        let next: @Sendable (URLRequest) async throws -> (Data, HTTPURLResponse) = { req in
            nextCalled.value = true
            Issue.record("next should not be called when tokenProvider throws")
            return makeOKResponse(for: req)
        }

        let sut = AuthenticationInterceptor { throw HTTPError.unknown(NSError(domain: "Auth", code: 401)) }
        let request = try URLRequest(url: #require(URL(string: "https://example.com")))

        do {
            _ = try await sut.intercept(request, next: next)
            Issue.record("Expected error to be thrown")
        } catch let error as HTTPError {
            if case .unknown = error {
                #expect(!nextCalled.value)
            } else {
                Issue.record("Unexpected error: \(error)")
            }
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }

    @Test("Overwrites existing Authorization header") func overwritesExistingAuthorizationHeader() async throws {
        let capturedRequest = Box<URLRequest?>(nil)
        let next: @Sendable (URLRequest) async throws -> (Data, HTTPURLResponse) = { req in
            capturedRequest.value = req
            return makeOKResponse(for: req)
        }

        let sut = AuthenticationInterceptor { "new-token" }
        var request = try URLRequest(url: #require(URL(string: "https://example.com")))
        request.setValue("Bearer old-token", forHTTPHeaderField: "Authorization")

        _ = try await sut.intercept(request, next: next)

        #expect(capturedRequest.value?.value(forHTTPHeaderField: "Authorization") == "Bearer new-token")
    }
}

// MARK: - Private Helpers

private func makeOKResponse(for request: URLRequest) -> (Data, HTTPURLResponse) {
    // swiftlint:disable:next force_unwrapping
    let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
    return (Data(), response)
}
