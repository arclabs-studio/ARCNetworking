//
//  StreamingView.swift
//  ExampleApp
//
//  Created by ARC Labs Studio on 11/03/26.
//

import ARCNetworking
import SwiftUI

/// Demonstrates SSE-style streaming via ``HTTPClientProtocol/stream(_:)``.
///
/// Calls ``StreamLinesEndpoint``, which receives line-delimited JSON from httpbin.
/// Each line delivered by the server is appended to the list in real time,
/// showing how to consume an ``AsyncThrowingStream`` of ``Data`` chunks.
struct StreamingView: View {
    @State private var lines: [String] = []
    @State private var isStreaming = false

    private let client = NetworkClientFactory.makeClient()

    var body: some View {
        NavigationStack {
            Group {
                if lines.isEmpty, !isStreaming {
                    ContentUnavailableView("No stream yet",
                                           systemImage: "dot.radiowaves.up.forward",
                                           description: Text("Tap Start to stream 5 lines"))
                } else {
                    List(lines.indices, id: \.self) { index in
                        Text(lines[index])
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundStyle(.primary)
                    }
                }
            }
            .navigationTitle("SSE Streaming")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    if isStreaming {
                        ProgressView()
                    } else {
                        Button("Start") {
                            Task { await startStreaming() }
                        }
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Clear") {
                        lines = []
                    }
                    .disabled(isStreaming)
                }
            }
        }
    }

    private func startStreaming() async {
        isStreaming = true

        let stream = client.stream(StreamLinesEndpoint(count: 5))
        do {
            for try await data in stream {
                if let line = String(data: data, encoding: .utf8), !line.isEmpty {
                    lines.append(line)
                }
            }
        } catch {
            lines.append("⚠️ \(error.localizedDescription)")
        }

        isStreaming = false
    }
}

#Preview {
    StreamingView()
}
