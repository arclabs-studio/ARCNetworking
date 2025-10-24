//
//  RequestBuilder.swift
//  ARCNetworking
//
//  Created by ARC Labs on 24/10/25.
//

import Foundation

public protocol RequestBuilderProtocol {
    func buildRequest(from endpoint: any Endpoint) throws -> URLRequest
}

public final class RequestBuilder: RequestBuilderProtocol {
    public init() {}
    
    public func buildRequest(from endpoint: any Endpoint) throws -> URLRequest {
        guard var components = URLComponents(url: endpoint.baseURL.appendingPathComponent(endpoint.path),
                                             resolvingAgainstBaseURL: false) else {
            throw HTTPError.invalidURL
        }
        components.queryItems = endpoint.queryItems
        
        guard let url = components.url else {
            throw HTTPError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body
        endpoint.headers?.forEach { request.addValue($1, forHTTPHeaderField: $0) }
        return request
    }
}


