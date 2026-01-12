//
//  PostDetailView.swift
//  ExampleApp
//
//  Created by ARC Labs Studio on 08/01/2026.
//

import SwiftUI

struct PostDetailView: View {
    let post: Post

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(post.title)
                    .font(.title)
                    .fontWeight(.bold)

                HStack {
                    Label("User \(post.userId)", systemImage: "person.circle")
                    Spacer()
                    Label("Post #\(post.id)", systemImage: "number")
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                Divider()

                Text(post.body)
                    .font(.body)
            }
            .padding()
        }
        .navigationTitle("Post Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        PostDetailView(
            post: Post(
                id: 1,
                userId: 1,
                title: "Sample Post Title",
                body: "This is the body of the sample post. It demonstrates how the detail view handles content."
            )
        )
    }
}
