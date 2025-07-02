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
            ContentView(viewModel: viewModel,
                        dropDelegate: fileDropDelegate)
        }
    }
    
}
