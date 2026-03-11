//
//  ContentView.swift
//  ExampleApp
//
//  Created by ARC Labs Studio on 08/01/2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            PostsView()
                .tabItem { Label("Posts", systemImage: "list.bullet") }
            StreamingView()
                .tabItem { Label("Streaming", systemImage: "dot.radiowaves.up.forward") }
        }
    }
}

#Preview {
    ContentView()
}
