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
                Tab(log.displayName, // TODO: give it a more meaningful name?
                    systemImage: "list.bullet.rectangle") {
                    LogView(log: log)
                }
            }
        }
        .toolbar {
            Menu {
                Button(action: viewModel.revealLogsInFinder) {
                    Text("Reveal logs in finder")
                }
                
                Button(action: viewModel.closeLogs) {
                    Text("Close logs")
                }
            } label: {
                Image(systemName: "list.bullet.circle.fill")
            }
        }
    }
    
}

#Preview {
    ContentView(viewModel: MockViewModel())
}

class MockViewModel: ViewModelInterface {
    
    private(set) var logs: [LogInfo]
    
    init() {
        logs = [
            LogInfo(filepath: URL(filePath: "filepath/invalid/short_content_log_filename.ext"),
                    content: "Some single line log content"),
            LogInfo(filepath: URL(filePath: "filepath/not-valid/long_content_log.ext"),
                    content: .loremIpsum)
        ]
    }
    
    func closeLogs() {
        logs = []
    }
    
    func revealLogsInFinder() {}
    
}
