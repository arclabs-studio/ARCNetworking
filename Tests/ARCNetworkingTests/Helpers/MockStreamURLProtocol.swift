//
//  MockStreamURLProtocol.swift
//  ARCNetworking
//
//  Created by ARC Labs Studio on 11/03/26.
//

import Foundation

/// Intercepts URLSession streaming requests during tests, delivering bytes in configurable chunks.
///
/// Use ``MockStreamURLProtocol/register(_:for:)`` to provide a handler per hostname.
/// The handler returns `(HTTPURLResponse, [Data])` where each `Data` element is delivered
/// as a separate chunk, simulating incremental streaming (e.g., SSE).
class MockStreamURLProtocol: URLProtocol {
    typealias StreamHandler = (URLRequest) throws -> (URLResponse, [Data])

    private static let lock = NSLock()
    private nonisolated(unsafe) static var handlers: [String: StreamHandler] = [:]

    static func register(_ handler: @escaping StreamHandler, for host: String) {
        lock.withLock { handlers[host] = handler }
    }

    static func unregister(host: String) {
        lock.withLock { _ = handlers.removeValue(forKey: host) }
    }

    private static func handler(for host: String) -> StreamHandler? {
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
            let (response, chunks) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            for chunk in chunks {
                client?.urlProtocol(self, didLoad: chunk)
            }
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
