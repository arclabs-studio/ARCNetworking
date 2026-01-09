//
//  PostRowView.swift
//  ExampleApp
//
//  Created by ARC Labs Studio on 08/01/2026.
//

import SwiftUI

struct PostRowView: View {
    let post: Post

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(post.title)
                .font(.headline)
                .lineLimit(2)
            Text(post.body)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    PostRowView(
        post: Post(
            id: 1,
            userId: 1,
            title: "Sample Post Title",
            body: "This is the body of the sample post."
        )
    )
}
