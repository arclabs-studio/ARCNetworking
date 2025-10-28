//
//  ARCNetworkServiceTests.swift
//  ARCNetworkingTests
//
//  Created by ARC Labs on 24/10/25.
//

import Foundation
import Testing
@testable import ARCNetworking

@Suite("ARCNetworkService", .serialized)
struct ARCNetworkServiceTests {
    
    // MARK: Mocks
    
    private struct MockEndpoint: Endpoint {
        struct ResponseModel: Codable, Equatable {
            let code: Int
            let message: String
        }
        
        typealias Response = ResponseModel
        
        var baseURL: URL { URL(string: "https://service-tests.arcnetworking")! }
        var path: String { "status" }
        var method: HTTPMethod { .GET }
        var headers: [String: String]? { nil }
        var queryItems: [URLQueryItem]? { nil }
        var body: Data? { nil }
    }
    
    private final class MockHTTPClient: HTTPClientProtocol {
        var callCount = 0
        var receivedPaths: [String] = []
        var executeClosure: ((Any) async throws -> Any)?
        
        func execute<T>(_ endpoint: T) async throws -> T.Response where T : Endpoint {
            callCount += 1
            receivedPaths.append(endpoint.path)
            guard let executeClosure else {
                Issue.record("No se stubbeó la respuesta del MockHTTPClient")
                throw HTTPError.unknown(URLError(.badServerResponse))
            }
            let anyResult = try await executeClosure(endpoint)
            guard let typedResult = anyResult as? T.Response else {
                fatalError("El tipo de respuesta \(type(of: anyResult)) no coincide con \(T.Response.self)")
            }
            return typedResult
        }
    }
    
    // MARK: Tests
    
    @Test("Delegación al cliente inyectado")
    func requestUsesInjectedClient() async throws {
        let endpoint = MockEndpoint()
        let expectedResponse = MockEndpoint.ResponseModel(code: 200, message: "OK")
        
        let mockClient = MockHTTPClient()
        mockClient.executeClosure = { anyEndpoint in
            #expect(anyEndpoint is MockEndpoint)
            return expectedResponse
        }
        
        let service = ARCNetworkService(client: mockClient)
        let response = try await service.request(endpoint)
        
        #expect(mockClient.callCount == 1)
        #expect(mockClient.receivedPaths == ["status"])
        #expect(response == expectedResponse)
    }
    
    @Test("Integración end-to-end utilizando HTTPClient real")
    func requestEndToEnd() async throws {
        defer { unregisterHandler() }
        let endpoint = MockEndpoint()
        let expectedResponse = MockEndpoint.ResponseModel(code: 201, message: "created")
        
        registerHandler { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            let data = try JSONEncoder().encode(expectedResponse)
            return (response, data)
        }
        
        let sut = makeSUT()
        let response = try await sut.request(endpoint)
        
        #expect(response == expectedResponse)
    }
    
    @Test("Propaga errores HTTPError provenientes del cliente")
    func requestPropagatesHTTPError() async {
        let endpoint = MockEndpoint()
        let expectedError = HTTPError.requestFailed(500)
        
        let mockClient = MockHTTPClient()
        mockClient.executeClosure = { _ in
            throw expectedError
        }
        
        let service = ARCNetworkService(client: mockClient)
        
        do {
            _ = try await service.request(endpoint)
            Issue.record("Se esperaba que la llamada re-lanzara HTTPError.requestFailed")
        } catch let error as HTTPError {
            if case .requestFailed(let code) = error {
                #expect(code == 500)
            } else {
                Issue.record("Error inesperado: \(error)")
            }
        } catch {
            Issue.record("Error inesperado de tipo distinto: \(error)")
        }
    }
}

// MARK: - Private Functions

private extension ARCNetworkServiceTests {
    func makeSUT() -> ARCNetworkService {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: configuration)
        let client = HTTPClient(session: session, builder: RequestBuilder())
        return ARCNetworkService(client: client)
    }
    
    func registerHandler(_ handler: @escaping MockURLProtocol.Handler) {
        MockURLProtocol.register(handler, for: "service-tests.arcnetworking")
    }
    
    func unregisterHandler() {
        MockURLProtocol.unregister(host: "service-tests.arcnetworking")
    }
}
