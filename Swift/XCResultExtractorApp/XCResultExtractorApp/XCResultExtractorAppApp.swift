//
//  XCResultExtractorAppApp.swift
//  XCResultExtractorApp
//
//  Created by Chris Mash on 11/05/2025.
//

import SwiftUI

@main
struct XCResultExtractorAppApp: App {
    
    private let fileDropDelegate = FileDropDelegate()
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onDrop(of: [.fileURL],
                        delegate: fileDropDelegate)
        }
    }
    
}
