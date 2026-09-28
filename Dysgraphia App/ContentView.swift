//
//  ContentView.swift
//  Dysgraphia App
//
//  Created by Prisha Mishra on 9/27/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        NavigationStack {
            HomeView()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
