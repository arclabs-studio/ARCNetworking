//
//  ContentView.swift
//  ARCNetworkingDemoApp
//
//  Created by ARC Labs Studio on 08/01/2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Posts", systemImage: "list.bullet") {
                PostsView()
            }
            Tab("Streaming", systemImage: "dot.radiowaves.up.forward") {
                StreamingView()
            }
        }
    }
}

#Preview {
    ContentView()
}
