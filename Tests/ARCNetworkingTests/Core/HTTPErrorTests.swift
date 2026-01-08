//
//  HTTPErrorTests.swift
//  ARCNetworking
//
//  Created by ARC Labs Studio on 24/10/25.
//

import Foundation
import Testing
@testable import ARCNetworking

@Suite("HTTPError")
struct HTTPErrorTests {
    @Test("Description for invalidURL")
    func invalidURLDescription() {
        let error = HTTPError.invalidURL
        let description = error.localizedDescription
        #expect(description.contains("invalid"))
    }

    @Test("Description for requestFailed includes status code")
    func requestFailedDescription() {
        let error = HTTPError.requestFailed(422)
        let description = error.localizedDescription
        #expect(description.contains("422"))
    }

    @Test("Description for decodingFailed includes underlying error")
    func decodingFailedDescription() {
        struct DummyError: Error {}
        let error = HTTPError.decodingFailed(DummyError())
        let description = error.localizedDescription
        #expect(description.contains("Failed to decode response"))
    }

    @Test("Description for unknown includes the underlying error message")
    func unknownDescription() {
        let underlying = URLError(.cannotConnectToHost)
        let error = HTTPError.unknown(underlying)
        let description = error.localizedDescription
        #expect(description.contains(underlying.localizedDescription))
    }
}
