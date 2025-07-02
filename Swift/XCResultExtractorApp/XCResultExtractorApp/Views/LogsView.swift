//
//  ContentView.swift
//  XCResultExtractorApp
//
//  Created by Chris Mash on 11/05/2025.
//

import SwiftUI

struct LogsView: View {
    
    let viewModel: ViewModelInterface
    
    @State private var hideNonsense = false
    
    var body: some View {
        TabView {
            ForEach(viewModel.state.logs) { log in
                Tab(log.displayName, // TODO: give it a more meaningful name?
                    systemImage: "list.bullet.rectangle") {
                    LogView(content: log
                                        .content
                                        .hidingNonsense(hideNonsense))
                }
            }
        }
        .padding(8)
        .toolbar {
            Menu {
                // TODO: toggle isn't updating the rendered content
                Toggle("Hide nonsense",
                       isOn: $hideNonsense) // TODO: not that nice UX with it in the menu, hard to tell what it's doing
                
                Divider()
                
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
