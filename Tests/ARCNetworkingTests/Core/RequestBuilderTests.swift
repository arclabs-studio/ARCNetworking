//
//  RequestBuilderTests.swift
//  ARCNetworking
//
//  Created by ARC Labs Studio on 24/10/25.
//

import Foundation
import HTTPTypes
import Testing
@testable import ARCNetworking

// MARK: - Test Fixtures

private struct RequestBuilderPayload: Codable, Equatable {
    let name: String
}

private struct MockRequestBuilderEndpoint: Endpoint {
    typealias Response = RequestBuilderPayload

    var baseURL: URL {
        // swiftlint:disable:next force_unwrapping
        URL(string: "https://example.com")!
    }

    var path: String {
        "api/v1/resource"
    }

    var method: HTTPMethod {
        .POST
    }

    var headers: [String: String]? {
        ["Content-Type": "application/json"]
    }

    var queryItems: [URLQueryItem]? {
        [URLQueryItem(name: "flag", value: "true")]
    }

    var body: Data? {
        try? JSONEncoder().encode(RequestBuilderPayload(name: "ARC"))
    }
}

private struct HTTPTypesEndpoint: Endpoint {
    typealias Response = [String: String]

    var baseURL: URL {
        // swiftlint:disable:next force_unwrapping
        URL(string: "https://example.com")!
    }

    var path: String {
        "api/v2/typed"
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

    var httpFields: HTTPFields? {
        var fields = HTTPFields()
        fields[.accept] = "application/json"
        // swiftlint:disable:next force_unwrapping
        fields[.init("X-ARC-Client")!] = "ARCNetworking"
        return fields
    }
}

private struct BodylessEndpoint: Endpoint {
    typealias Response = [String: String]

    var baseURL: URL {
        // swiftlint:disable:next force_unwrapping
        URL(string: "https://example.com")!
    }

    var path: String {
        "ping"
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

// MARK: - Tests

@Suite("RequestBuilder") struct RequestBuilderTests {
    @Test("Builds a URLRequest with all components") func buildRequestAppliesAllEndpointData() throws {
        let builder = RequestBuilder()
        let endpoint = MockRequestBuilderEndpoint()

        let request = try builder.buildRequest(from: endpoint)

        #expect(request.httpMethod == "POST")
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
        #expect(request.url?.absoluteString == "https://example.com/api/v1/resource?flag=true")

        let body = try #require(request.httpBody)
        let payload = try JSONDecoder().decode(RequestBuilderPayload.self, from: body)
        #expect(payload == .init(name: "ARC"))
    }

    @Test("Builds a GET request without body or headers") func buildRequestHandlesEmptyOptionalValues() throws {
        let builder = RequestBuilder()
        let endpoint = BodylessEndpoint()

        let request = try builder.buildRequest(from: endpoint)

        #expect(request.httpMethod == "GET")
        #expect(request.allHTTPHeaderFields?.isEmpty ?? true)
        #expect(request.httpBody == nil)
    }

    @Test("Builds URLRequest using HTTPTypesFoundation when httpFields provided")
    func buildRequestUsesHTTPTypesFoundationWhenHttpFieldsPresent() throws {
        let builder = RequestBuilder()
        let endpoint = HTTPTypesEndpoint()

        let request = try builder.buildRequest(from: endpoint)

        #expect(request.httpMethod == "GET")
        #expect(request.value(forHTTPHeaderField: "Accept") == "application/json")
        #expect(request.value(forHTTPHeaderField: "X-ARC-Client") == "ARCNetworking")
        #expect(request.url?.absoluteString == "https://example.com/api/v2/typed")
    }

    @Test("Falls back to legacy headers when httpFields is nil")
    func buildRequestUsesLegacyHeadersWhenHttpFieldsNil() throws {
        let builder = RequestBuilder()
        let endpoint = MockRequestBuilderEndpoint()

        // httpFields defaults to nil — legacy path is taken
        #expect(endpoint.httpFields == nil)

        let request = try builder.buildRequest(from: endpoint)

        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
    }
}
