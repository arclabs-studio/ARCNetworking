//
//  ARCNetworkService.swift
//  ARCNetworking
//
//  Created by ARC Labs on 24/10/25.
//

import Foundation

public protocol ARCNetworkServiceProtocol {
    func request<T: Endpoint>(_ endpoint: T) async throws -> T.Response
}

public final class ARCNetworkService: ARCNetworkServiceProtocol {
    private let client: HTTPClientProtocol
    
    public init(client: HTTPClientProtocol = HTTPClient()) {
        self.client = client
    }
    
    public func request<T>(_ endpoint: T) async throws -> T.Response where T : Endpoint {
        try await client.execute(endpoint)
    }
}

