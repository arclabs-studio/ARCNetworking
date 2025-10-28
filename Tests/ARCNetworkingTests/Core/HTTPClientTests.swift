//
//  HTTPClientTests.swift
//  ARCNetworkingTests
//
//  Created by ARC Labs on 24/10/25.
//

import Foundation
import Testing
@testable import ARCNetworking

@Suite("HTTPClient", .serialized)
struct HTTPClientTests {
    
    // MARK: Mocks

    private struct MockEndpoint: Endpoint {
        struct ResponseModel: Codable, Equatable {
            let id: Int
            let title: String
        }
        
        typealias Response = ResponseModel
        
        var baseURL: URL { URL(string: "https://client-tests.arcnetworking")! }
        var path: String { "articles/42" }
        var method: HTTPMethod { .GET }
        var headers: [String: String]? { nil }
        var queryItems: [URLQueryItem]? { nil }
        var body: Data? { nil }
    }
    
    // MARK: Tests

    @Test("Decodes a successful response")
    func executeReturnsDecodedResponse() async throws {
        defer { unregisterHandler() }
        let expectedModel = MockEndpoint.ResponseModel(id: 42, title: "ARC Networking Rocks")
        registerHandler { request in
            #expect(request.url?.absoluteString == "https://client-tests.arcnetworking/articles/42")
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            let data = try JSONEncoder().encode(expectedModel)
            return (response, data)
        }
        
        let endpoint = MockEndpoint()
        let sut = makeSUT()
        
        let result = try await sut.execute(endpoint)
        #expect(result == expectedModel)
    }
    
    @Test("Propagates errors for non-2xx status codes")
    func executeThrowsForHTTPError() async {
        defer { unregisterHandler() }
        registerHandler { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 404, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }
        
        let endpoint = MockEndpoint()
        let sut = makeSUT()
        
        do {
            _ = try await sut.execute(endpoint)
            Issue.record("Expected HTTPError.requestFailed")
        } catch let error as HTTPError {
            if case .requestFailed(let statusCode) = error {
                #expect(statusCode == 404)
            } else {
                Issue.record("Unexpected error: \(error)")
            }
        } catch {
            Issue.record("Unexpected error of different type: \(error)")
        }
    }
    
    @Test("Throws HTTPError.decodingFailed when decoding fails")
    func executeThrowsForDecodingError() async {
        defer { unregisterHandler() }
        registerHandler { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            let invalidJSON = Data("{\"unexpected\":true}".utf8)
            return (response, invalidJSON)
        }
        
        let endpoint = MockEndpoint()
        let sut = makeSUT()
        
        do {
            _ = try await sut.execute(endpoint)
            Issue.record("Expected HTTPError.decodingFailed")
        } catch let error as HTTPError {
            if case .decodingFailed = error {
                // Expected
            } else {
                Issue.record("Unexpected error: \(error)")
            }
        } catch {
            Issue.record("Unexpected error of different type: \(error)")
        }
    }
    
    @Test("Throws HTTPError.unknown when the response is non-HTTP")
    func executeThrowsUnknownForNonHTTPResponse() async {
        defer { unregisterHandler() }
        registerHandler { request in
            let response = URLResponse(url: request.url!, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
            return (response, Data())
        }
        
        let endpoint = MockEndpoint()
        let sut = makeSUT()
        
        do {
            _ = try await sut.execute(endpoint)
            Issue.record("Expected HTTPError.unknown")
        } catch let error as HTTPError {
            if case .unknown = error {
                // Expected
            } else {
                Issue.record("Unexpected error: \(error)")
            }
        } catch {
            Issue.record("Unexpected error of different type: \(error)")
        }
    }
    
    @Test("Propagates URLSession transport errors")
    func executePropagatesTransportError() async {
        defer { unregisterHandler() }
        registerHandler { _ in
            throw URLError(.notConnectedToInternet)
        }
        
        let endpoint = MockEndpoint()
        let sut = makeSUT()
        
        do {
            _ = try await sut.execute(endpoint)
            Issue.record("Expected URLError")
        } catch let error as URLError {
            #expect(error.code == .notConnectedToInternet)
        } catch {
            Issue.record("Unexpected error of different type: \(error)")
        }
    }
}

// MARK: - Private Functions

private extension HTTPClientTests {
    func makeSUT() -> HTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: configuration)
        return HTTPClient(session: session, builder: RequestBuilder())
    }
    
    func registerHandler(_ handler: @escaping MockURLProtocol.Handler) {
        MockURLProtocol.register(handler, for: "client-tests.arcnetworking")
    }
    
    func unregisterHandler() {
        MockURLProtocol.unregister(host: "client-tests.arcnetworking")
    }
}
