//
//  ViewModel.swift
//  XCResultExtractorApp
//
//  Created by Chris Mash on 11/05/2025.
//

import Foundation

struct LogInfo: Identifiable {
    
    let id = UUID()
    let displayName: String
    let filepath: URL
    let content: String
    
    init(filepath: URL,
         content: String) {
        self.filepath = filepath
        self.content = content
        
        // The filename is likely to be something like "TestAppUITests-com.chrismash.TestApp.txt".
        // The following drops off the file extension, in perhaps a roundabout way
        let filenameComponents = filepath.lastPathComponent.components(separatedBy: ".")
        let componentRangeWithoutExt = filenameComponents.startIndex..<filenameComponents.endIndex.advanced(by: -1)
        displayName = filenameComponents[componentRangeWithoutExt].joined(separator: ".")
    }
    
}

protocol ViewModelInterface {
    
    var logs: [LogInfo] { get }
    
    func closeLogs()
    func revealLogsInFinder()
    
}

@Observable
class ViewModel: ViewModelInterface {
    
    private(set) var logs: [LogInfo] = [] // TODO: can be modified externally?
    
    func closeLogs() {
        logs = []
    }
    
    func revealLogsInFinder() {
        logs[0]
            .filepath
            .deletingLastPathComponent()
            .revealInFinder()
    }
    
}

extension ViewModel: FileDropDelegate.FileReceiver {
    
    func filesReceived(_ files: [URL]) {
        files.forEach {
            do {
                let content = try String(contentsOf: $0,
                                         encoding: .utf8)
                logs.append(LogInfo(filepath: $0,
                                    content: content))
            } catch {
                print("Failed to load \($0): \(error)")
            }
        }
    }
    
}
