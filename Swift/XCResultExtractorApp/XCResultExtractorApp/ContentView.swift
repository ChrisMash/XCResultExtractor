//
//  ContentView.swift
//  XCResultExtractorApp
//
//  Created by Chris Mash on 11/05/2025.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "document.badge.plus")
                .imageScale(.large)
                .font(.title)
            Text("Drag an .xcresult file here!")
                .font(.headline)
        }
        // TODO: do an openFileDialog too?
    }
    
}

#Preview {
    ContentView()
}
