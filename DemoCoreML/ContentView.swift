//
//  ContentView.swift
//  DemoCoreML
//
//  Created by Unthinkable-Mac on 14/09/26.
//

import SwiftUI
internal import UniformTypeIdentifiers

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("What?", systemImage: "photo.circle") {
                ImageClassifierView()
            }
            Tab("How much?", systemImage: "dot.scope") {
                FindDepthView()
            }
        }
    }
}

#Preview {
    ContentView()
}
