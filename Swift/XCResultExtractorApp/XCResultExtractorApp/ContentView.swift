//
//  ContentView.swift
//  XCResultExtractorApp
//
//  Created by Chris Mash on 11/05/2025.
//

import SwiftUI

struct ContentView: View {
    
    let viewModel: ViewModelInterface
    
    var body: some View {
        TabView {
            ForEach(viewModel.logs) { log in
                Tab(log.filename, // TODO: gets cut off? useful to give it a meaningful name anyway
                    systemImage: "list.bullet.rectangle") {
                    ScrollView {
                        Text(log.content)
                            .multilineTextAlignment(.leading)
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity,
                                   maxHeight: .infinity,
                                   alignment: .leading)
                            .padding()
                    }
                    // TODO: button to get hold of the file (export or folder open)
                }
            }
        }
    }
    
}

#Preview {
    ContentView(viewModel: MockViewModel())
}

class MockViewModel: ViewModelInterface {
    
    let logs: [LogInfo]
    
    init() {
        logs = [
            LogInfo(filename: "short_content_log_filename.ext",
                    content: "Some single line log content"),
            LogInfo(filename: "long_content_log",
                    content: .loremIpsum)
        ]
    }
    
}
