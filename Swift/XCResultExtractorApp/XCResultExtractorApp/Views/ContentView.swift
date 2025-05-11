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
        TabView { // TODO: a bit laggy changing tabs, may be very laggy with 100k logs?
            ForEach(viewModel.logs) { log in
                Tab(log.filename, // TODO: give it a more meaningful name?
                    systemImage: "list.bullet.rectangle") {
                    LogView(log: log)
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
