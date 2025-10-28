//
//  HTTPErrorTests.swift
//  ARCNetworkingTests
//
//  Created by ARC Labs on 24/10/25.
//

import Foundation
import Testing
@testable import ARCNetworking

@Suite("HTTPError")
struct HTTPErrorTests {
    
    @Test("Descripción para invalidURL")
    func invalidURLDescription() {
        let error = HTTPError.invalidURL
        let description = error.localizedDescription
        #expect(description.contains("invalid"))
    }
    
    @Test("Descripción para requestFailed incluye status code")
    func requestFailedDescription() {
        let error = HTTPError.requestFailed(422)
        let description = error.localizedDescription
        #expect(description.contains("422"))
    }
    
    @Test("Descripción para decodingFailed muestra el error original")
    func decodingFailedDescription() {
        struct DummyError: Error {}
        let error = HTTPError.decodingFailed(DummyError())
        let description = error.localizedDescription
        #expect(description.contains("Failed to decode response"))
    }
    
    @Test("Descripción para unknown propaga el mensaje del error subyacente")
    func unknownDescription() {
        let underlying = URLError(.cannotConnectToHost)
        let error = HTTPError.unknown(underlying)
        let description = error.localizedDescription
        #expect(description.contains(underlying.localizedDescription))
    }
}
