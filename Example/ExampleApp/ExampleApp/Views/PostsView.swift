//
//  PostsView.swift
//  ExampleApp
//
//  Created by ARC Labs Studio on 11/03/26.
//

import ARCNetworking
import SwiftUI

/// Demonstrates fetching posts via an ``HTTPClient`` configured with a full interceptor
/// pipeline (``AuthenticationInterceptor`` → ``RetryInterceptor`` → ``LoggingInterceptor``)
/// and a ``PostsEndpoint`` that uses type-safe ``HTTPFields`` headers via HTTPTypes.
struct PostsView: View {
    @State private var posts: [Post] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    /// Client pre-configured with interceptors via ``NetworkClientFactory``.
    private let client = NetworkClientFactory.makeClient()

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading posts...")
                } else if let errorMessage {
                    ContentUnavailableView {
                        Label("Error", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(errorMessage)
                    } actions: {
                        Button("Retry") {
                            Task { await loadPosts() }
                        }
                    }
                } else if posts.isEmpty {
                    ContentUnavailableView("No Posts",
                                           systemImage: "doc.text",
                                           description: Text("Tap the button to load posts"))
                } else {
                    List(posts) { post in
                        NavigationLink(destination: PostDetailView(post: post)) {
                            PostRowView(post: post)
                        }
                    }
                }
            }
            .navigationTitle("Posts (httpFields)")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        Task { await loadPosts() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(isLoading)
                }
            }
        }
        .task {
            await loadPosts()
        }
    }

    private func loadPosts() async {
        isLoading = true
        errorMessage = nil

        do {
            // PostsEndpoint uses HTTPFields — RequestBuilder takes the HTTPTypesFoundation path
            posts = try await client.execute(PostsEndpoint())
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

#Preview {
    PostsView()
}
