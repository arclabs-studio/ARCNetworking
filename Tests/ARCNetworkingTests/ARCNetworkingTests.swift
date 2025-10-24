//
//  ARCNetworkingTests.swift
//  ARCNetworking
//
//  Created by ARC Labs on 24/10/25.
//

import Foundation
import Testing
@testable import ARCNetworking

struct ARCNetworkingTests {
    
    // MARK: Mock
    
    private struct MockEndpoint: Endpoint {
        typealias Response = [String: String]
        
        var baseURL: URL { URL(string: "https://example.com")! }
        var path: String { "mock" }
        var method: HTTPMethod { .GET }
        var headers: [String : String]? { ["Authorization": "Bearer token"] }
        var queryItems: [URLQueryItem]? { [URLQueryItem(name: "test", value: "true")] }
        var body: Data? { nil }
    }
    
    // MARK: Tests
    
    @Test
    func requestBuilderCreatesValidRequest() throws {
        let builder = RequestBuilder()
        let endpoint = MockEndpoint()
        
        let request = try builder.buildRequest(from: endpoint)
        
        #expect(request.url?.absoluteString.contains("example.com/mock") == true)
        #expect(request.httpMethod == "GET")
        #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer token")
    }
    
    @Test
    func httpErrorDescription() {
        let error = HTTPError.requestFailed(404)
        #expect(error.localizedDescription.contains("404"))
    }
}

