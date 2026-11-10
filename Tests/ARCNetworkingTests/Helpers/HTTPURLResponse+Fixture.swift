//
//  HTTPURLResponse+Fixture.swift
//  ARCNetworking
//
//  Created by ARC Labs Studio on 05/11/26.
//

import Foundation

extension HTTPURLResponse {
    /// Builds a canned response for a stubbed request, throwing instead of force-unwrapping.
    static func fixture(url: URL?, statusCode: Int) throws -> HTTPURLResponse {
        guard let url,
              let response = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)
        else {
            throw URLError(.badURL)
        }
        return response
    }
}
