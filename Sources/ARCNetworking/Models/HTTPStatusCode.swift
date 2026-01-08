//
//  HTTPStatusCode.swift
//  ARCNetworking
//
//  Created by ARC Labs Studio on 05/01/26.
//

import Foundation

/// Constants for HTTP status codes and ranges.
public enum HTTPStatusCode {
    /// The range of successful HTTP status codes (200-299).
    public static let successRange = 200 ..< 300

    /// Common HTTP status codes.
    public static let ok = 200
    public static let created = 201
    public static let accepted = 202
    public static let noContent = 204

    public static let badRequest = 400
    public static let unauthorized = 401
    public static let forbidden = 403
    public static let notFound = 404
    public static let conflict = 409
    public static let unprocessableEntity = 422

    public static let internalServerError = 500
    public static let badGateway = 502
    public static let serviceUnavailable = 503
}
