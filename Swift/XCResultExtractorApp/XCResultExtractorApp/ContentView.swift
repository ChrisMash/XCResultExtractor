//
//  ContentView.swift
//  XCResultExtractorApp
//
//  Created by Chris Mash on 11/05/2025.
//

import SwiftUI

struct ContentView: View {
    
    let viewModel: ViewModel
    
    var body: some View {
        if viewModel.logs.isEmpty {
            VStack(spacing: 10) {
                Image(systemName: "document.badge.plus")
                    .imageScale(.large)
                    .font(.title)
                Text("Drag an .xcresult file here!")
                    .font(.headline)
            }
            // TODO: expand to fill window so can be dropped anywhere
            // TODO: do an openFileDialog too?
            // TODO: how to load new xcresult?
        } else {
            TabView {
                ForEach(viewModel.logs) { log in
                    Tab(log.filename, // TODO: gets cut off? useful to give it a meaningful name anyway
                        systemImage: "list.bullet.rectangle") {
                        ScrollView {
                            Text(log.content)
                                .multilineTextAlignment(.leading)
                                .textSelection(.enabled)
                                .padding()
                            // TODO: needs to fill full width
                        }
                        // TODO: button to get hold of the file (export or folder open)
                    }
                }
            }
        }
    }
    
}

#Preview {
    ContentView(viewModel: ViewModel())
}
