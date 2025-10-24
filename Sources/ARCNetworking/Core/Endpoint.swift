//
//  Endpoint.swift
//  ARCNetworking
//
//  Created by ARC Labs on 24/10/25.
//

import Foundation

public protocol Endpoint {
    associatedtype Response: Decodable
    
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var queryItems: [URLQueryItem]? { get }
    var body: Data? { get }
}
