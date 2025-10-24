//
//  ARCNetworkLogger.swift
//  ARCNetworking
//
//  Created by ARC Labs on 24/10/25.
//

import Foundation
import os

public enum ARCNetworkLogger {
    
    // MARK: Private Properties

    private static let logger = Logger(subsystem: "com.carlosrasensio.networking", category: "HTTP")
    
    // MARK: Public Functions
    
    public static func log(request: URLRequest) {
        #if DEBUG
        print("\n🔵 [NETWORK] ---------------------------------------------")
        print("➡️ Request: \(request.httpMethod ?? "") \(request.url?.absoluteString ?? "")")
        
        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            print("📦 Headers:")
            headers.forEach { print("   \($0): \($1)") }
        }
        
        if let body = request.httpBody,
           let bodyString = String(data: body, encoding: .utf8),
           !bodyString.isEmpty {
            print("📨 Body:\n\(bodyString)")
        }
        
        logger.debug("➡️ Request: \(request.httpMethod ?? "") \(request.url?.absoluteString ?? "")")
        #endif
    }
    
    public static func log(response: URLResponse?, data: Data?) {
        #if DEBUG
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ No valid HTTPURLResponse")
            return
        }
        
        print("⬅️ Response: \(httpResponse.statusCode) \(httpResponse.url?.absoluteString ?? "")")
        
        if let data = data,
           let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
           let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
           let jsonString = String(data: prettyData, encoding: .utf8) {
            print("📦 Response JSON:\n\(jsonString)")
        } else if let data = data,
                  let text = String(data: data, encoding: .utf8),
                  !text.isEmpty {
            print("📦 Response Text:\n\(text)")
        }
        
        print("----------------------------------------------------------\n")
        logger.debug("⬅️ Response: \(httpResponse.statusCode) \(httpResponse.url?.absoluteString ?? "")")
        #endif
    }
    
    public static func log(error: Error) {
        #if DEBUG
        print("❌ [ERROR] \(error.localizedDescription)")
        logger.error("❌ \(error.localizedDescription, privacy: .public)")
        #endif
    }
}
