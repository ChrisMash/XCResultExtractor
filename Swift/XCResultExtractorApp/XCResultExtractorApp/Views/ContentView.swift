//
//  ContentView.swift
//  XCResultExtractorApp
//
//  Created by Chris Mash on 02/07/2025.
//

import SwiftUI

struct ContentView: View {
    
    let viewModel: ViewModelInterface
    let dropDelegate: DropDelegate
    
    var body: some View {
        switch viewModel.state {
        case .idle:
            DropperView(delegate: dropDelegate)
        case .loading:
            VStack {
                ProgressView() // TODO: provide progress feedback (progress incremented per log perhaps)
                Text("Loading...")
            }
            // TODO: not picking up transition from loading to loaded, beachballing
        case .logsLoaded(_):
            LogsView(viewModel: viewModel) // TODO: perhaps doesn't need whole viewModel, just logs..?
        case .error(let error):
            VStack {
                DropperView(delegate: dropDelegate)
                
                ErrorView(error: error)
                    .padding()
            }
        }
    }
    
}

#Preview("idle") {
    ContentView(viewModel: MockViewModel(state: .idle),
                dropDelegate: MockDropDelegate())
}

#Preview("loading") {
    ContentView(viewModel: MockViewModel(state: .loading),
                dropDelegate: MockDropDelegate())
}

#Preview("logs") {
    ContentView(viewModel: MockViewModel(state: .previewLogs),
                dropDelegate: MockDropDelegate())
}

#Preview("error") {
    ContentView(viewModel: MockViewModel(state: .error(NSError(domain: "PRVW",
                                                               code: 0))),
                dropDelegate: MockDropDelegate())
}
