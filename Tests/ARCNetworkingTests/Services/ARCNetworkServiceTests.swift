//
//  ARCNetworkServiceTests.swift
//  ARCNetworking
//
//  Created by ARC Labs Studio on 24/10/25.
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

    // Mock client for testing - @unchecked Sendable since access is controlled in test context
    private final class MockHTTPClient: HTTPClientProtocol, @unchecked Sendable {
        var callCount = 0
        var receivedPaths: [String] = []
        var executeClosure: ((Any) async throws -> Any)?

        func execute<T>(_ endpoint: T) async throws -> T.Response where T: Endpoint {
            callCount += 1
            receivedPaths.append(endpoint.path)
            guard let executeClosure else {
                Issue.record("MockHTTPClient response was not stubbed")
                throw HTTPError.unknown(URLError(.badServerResponse))
            }
            let anyResult = try await executeClosure(endpoint)
            guard let typedResult = anyResult as? T.Response else {
                fatalError("Response type \(type(of: anyResult)) does not match \(T.Response.self)")
            }
            return typedResult
        }
    }

    // MARK: Tests

    @Test("Delegates to the injected client")
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

    @Test("End-to-end integration using the real HTTPClient")
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

    @Test("Propagates HTTPError instances thrown by the client")
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
            Issue.record("Expected the call to rethrow HTTPError.requestFailed")
        } catch let error as HTTPError {
            if case let .requestFailed(code) = error {
                #expect(code == 500)
            } else {
                Issue.record("Unexpected error: \(error)")
            }
        } catch {
            Issue.record("Unexpected error of different type: \(error)")
        }
    }
}

// MARK: - Private Functions

extension ARCNetworkServiceTests {
    private func makeSUT() -> ARCNetworkService {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: configuration)
        let client = HTTPClient(session: session, builder: RequestBuilder())
        return ARCNetworkService(client: client)
    }

    private func registerHandler(_ handler: @escaping MockURLProtocol.Handler) {
        MockURLProtocol.register(handler, for: "service-tests.arcnetworking")
    }

    private func unregisterHandler() {
        MockURLProtocol.unregister(host: "service-tests.arcnetworking")
    }
}
