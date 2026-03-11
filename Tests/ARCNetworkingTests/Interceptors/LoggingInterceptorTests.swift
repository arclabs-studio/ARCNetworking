//
//  LoggingInterceptorTests.swift
//  ARCNetworking
//
//  Created by ARC Labs Studio on 11/03/26.
//

import Foundation
import Testing
@testable import ARCNetworking

// MARK: - Helpers

private final class Box<T>: @unchecked Sendable {
    var value: T
    init(_ value: T) {
        self.value = value
    }
}

// MARK: - Tests

@Suite("LoggingInterceptor") struct LoggingInterceptorTests {
    @Test("Passes request and response through unmodified") func passesThroughUnmodified() async throws {
        let originalURL = try #require(URL(string: "https://logging-tests.arcnetworking/test"))
        var originalRequest = URLRequest(url: originalURL)
        originalRequest.httpMethod = "POST"
        originalRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let expectedData = Data("hello".utf8)
        let expectedResponse = try #require(HTTPURLResponse(url: originalURL, statusCode: 201, httpVersion: nil,
                                                            headerFields: nil))

        let receivedRequest = Box<URLRequest?>(nil)
        let next: @Sendable (URLRequest) async throws -> (Data, HTTPURLResponse) = { req in
            receivedRequest.value = req
            return (expectedData, expectedResponse)
        }

        let sut = LoggingInterceptor()
        let (data, response) = try await sut.intercept(originalRequest, next: next)

        // Request forwarded unchanged
        #expect(receivedRequest.value?.url == originalURL)
        #expect(receivedRequest.value?.httpMethod == "POST")
        #expect(receivedRequest.value?.value(forHTTPHeaderField: "Content-Type") == "application/json")

        // Response returned unchanged
        #expect(data == expectedData)
        #expect(response.statusCode == 201)
    }
}
