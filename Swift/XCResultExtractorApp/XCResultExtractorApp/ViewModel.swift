//
//  ViewModel.swift
//  XCResultExtractorApp
//
//  Created by Chris Mash on 11/05/2025.
//

import Foundation

@Observable
class ViewModel {
    
    struct LogInfo: Identifiable {
        let id = UUID()
        let filename: String
        let content: String
    }
    
    private(set) var logs: [LogInfo] = [] // TODO: can be modified externally?
    
}

extension ViewModel: FileDropDelegate.FileReceiver {
    
    func filesReceived(_ files: [URL]) {
        files.forEach {
            do {
                let content = try String(contentsOf: $0,
                                         encoding: .utf8)
                logs.append(LogInfo(filename: $0.lastPathComponent.components(separatedBy: ".")[0],
                                    content: content))
            } catch {
                print("Failed to load \($0): \(error)")
            }
        }
    }
    
}
