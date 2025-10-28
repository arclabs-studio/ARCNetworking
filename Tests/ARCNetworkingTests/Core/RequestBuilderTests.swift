//
//  RequestBuilderTests.swift
//  ARCNetworkingTests
//
//  Created by ARC Labs on 24/10/25.
//

import Foundation
import Testing
@testable import ARCNetworking

@Suite("RequestBuilder")
struct RequestBuilderTests {
    
    // MARK: Mocks
    
    private struct MockEndpoint: Endpoint {
        struct Payload: Codable, Equatable {
            let name: String
        }
        
        typealias Response = Payload
        
        var baseURL: URL { URL(string: "https://example.com")! }
        var path: String { "api/v1/resource" }
        var method: HTTPMethod { .POST }
        var headers: [String: String]? { ["Content-Type": "application/json"] }
        var queryItems: [URLQueryItem]? { [URLQueryItem(name: "flag", value: "true")] }
        var body: Data? { try? JSONEncoder().encode(Payload(name: "ARC")) }
    }
    
    private struct BodylessEndpoint: Endpoint {
        typealias Response = [String: String]
        
        var baseURL: URL { URL(string: "https://example.com")! }
        var path: String { "ping" }
        var method: HTTPMethod { .GET }
        var headers: [String: String]? { nil }
        var queryItems: [URLQueryItem]? { nil }
        var body: Data? { nil }
    }
    
    // MARK: Tests
    
    @Test("Builds a URLRequest with all components")
    func buildRequestAppliesAllEndpointData() throws {
        let builder = RequestBuilder()
        let endpoint = MockEndpoint()
        
        let request = try builder.buildRequest(from: endpoint)
        
        #expect(request.httpMethod == "POST")
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
        #expect(request.url?.absoluteString == "https://example.com/api/v1/resource?flag=true")
        
        let body = try #require(request.httpBody)
        let payload = try JSONDecoder().decode(MockEndpoint.Payload.self, from: body)
        #expect(payload == .init(name: "ARC"))
    }
    
    @Test("Builds a GET request without body or headers")
    func buildRequestHandlesEmptyOptionalValues() throws {
        let builder = RequestBuilder()
        let endpoint = BodylessEndpoint()
        
        let request = try builder.buildRequest(from: endpoint)
        
        #expect(request.httpMethod == "GET")
        #expect(request.allHTTPHeaderFields?.isEmpty ?? true)
        #expect(request.httpBody == nil)
    }
}
