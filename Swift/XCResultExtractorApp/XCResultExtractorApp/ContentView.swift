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

#Preview {
    ContentView(viewModel: ViewModel())
}
