//
//  Post.swift
//  ExampleApp
//
//  Created by ARC Labs Studio on 08/01/2026.
//

import Foundation

/// A post from the JSONPlaceholder API.
struct Post: Decodable, Identifiable {
    let id: Int
    let userId: Int
    let title: String
    let body: String
}
