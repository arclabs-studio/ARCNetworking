//
//  HTTPMethod.swift
//  ARCNetworking
//
//  Created by ARC Labs Studio on 24/10/25.
//

import Foundation

/// HTTP methods supported by the networking layer.
public enum HTTPMethod: String, Sendable {
    /// HTTP GET method for retrieving resources.
    case GET
    /// HTTP POST method for creating resources.
    case POST
    /// HTTP PUT method for replacing resources.
    case PUT
    /// HTTP DELETE method for removing resources.
    case DELETE
    /// HTTP PATCH method for partial resource updates.
    case PATCH
}
