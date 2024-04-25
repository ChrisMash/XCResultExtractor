//
//  ContentView.swift
//  TestApp
//
//  Created by Chris Mash on 25/04/2024.
//

import SwiftUI

struct ContentView: View {
    
    init() {
        print("ContentView initialised")
    }
    
    var body: some View {
        Self._printChanges()
        return VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
    
}

#Preview {
    ContentView()
}
