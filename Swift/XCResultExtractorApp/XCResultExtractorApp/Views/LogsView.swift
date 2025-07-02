//
//  ContentView.swift
//  XCResultExtractorApp
//
//  Created by Chris Mash on 11/05/2025.
//

import SwiftUI

struct LogsView: View {
    
    let viewModel: ViewModelInterface
    
    var body: some View {
//        TabView {
//            ForEach(viewModel.state.logs) { log in
//                Tab(log.displayName,
//                    systemImage: "list.bullet.rectangle") {
//                    Text(verbatim: .loremIpsum)
//                }
//            }
//        }
        TabView { // TODO: changing tabs hella laggy & beachball for a bit when logs are large
            ForEach(viewModel.state.logs) { log in
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

#Preview("2 logs") {
    LogsView(viewModel: MockViewModel(state: .previewLogs))
}

#Preview("0 logs") {
    // TODO: would want to show an error and back to dropper.. or just never get to this view
    LogsView(viewModel: MockViewModel(state: .logsLoaded([])))
}
