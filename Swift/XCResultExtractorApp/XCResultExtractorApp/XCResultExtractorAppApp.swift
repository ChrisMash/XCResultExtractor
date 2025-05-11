//
//  XCResultExtractorAppApp.swift
//  XCResultExtractorApp
//
//  Created by Chris Mash on 11/05/2025.
//

import SwiftUI

@main
struct XCResultExtractorAppApp: App {
    
    private let viewModel = ViewModel()
    private let fileDropDelegate = FileDropDelegate()
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    init() {
        fileDropDelegate.fileReceiver = viewModel
    }
    
    var body: some Scene {
        WindowGroup {
            switch viewModel.state {
            case .idle:
                DropperView(delegate: fileDropDelegate)
            case .logsLoaded(_):
                ContentView(viewModel: viewModel)
            case .error(let error):
                VStack {
                    DropperView(delegate: fileDropDelegate)
                    
                    ErrorView(error: error)
                        .padding()
                }
            }
        }
    }
    
}
