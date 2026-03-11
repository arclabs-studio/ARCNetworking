//
//  MockURLProtocol.swift
//  ARCNetworking
//
//  Created by ARC Labs Studio on 24/10/25.
//

import Foundation

/// Intercepts URLSession requests during tests to provide deterministic responses.
class MockURLProtocol: URLProtocol {
    typealias Handler = (URLRequest) throws -> (URLResponse, Data)

    private static let lock = NSLock()
    /// Protected by lock - safe for concurrent access
    private nonisolated(unsafe) static var handlers: [String: Handler] = [:]

    static func register(_ handler: @escaping Handler, for host: String) {
        lock.withLock { handlers[host] = handler }
    }

    static func unregister(host: String) {
        lock.withLock { _ = handlers.removeValue(forKey: host) }
    }

    private static func handler(for host: String) -> Handler? {
        lock.withLock { handlers[host] }
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
