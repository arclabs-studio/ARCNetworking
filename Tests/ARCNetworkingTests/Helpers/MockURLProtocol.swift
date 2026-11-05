//
//  MockURLProtocol.swift
//  ARCNetworking
//
//  Created by ARC Labs Studio on 24/10/25.
//

import Foundation
import os

/// Intercepts URLSession requests during tests to provide deterministic responses.
class MockURLProtocol: URLProtocol {
    typealias Handler = @Sendable (URLRequest) throws -> (URLResponse, Data)

    private static let handlers = OSAllocatedUnfairLock<[String: Handler]>(initialState: [:])

    static func register(_ handler: @escaping Handler, for host: String) {
        handlers.withLock { $0[host] = handler }
    }

    static func unregister(host: String) {
        handlers.withLock { _ = $0.removeValue(forKey: host) }
    }

    private static func handler(for host: String) -> Handler? {
        handlers.withLock { $0[host] }
    }

    override class func canInit(with _: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let host = request.url?.host,
              let handler = Self.handler(for: host)
        else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
