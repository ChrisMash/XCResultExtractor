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

enum ViewModelState {
    
    case idle
    case loading
    case logsLoaded([LogInfo])
    case error(Error)
    
    var logs: [LogInfo] {
        switch self {
        case .logsLoaded(let logs):
            return logs
        default:
            return []
        }
    }
    
    static let previewLogs: Self = .logsLoaded([
        LogInfo(filepath: URL(filePath: "filepath/invalid/short_content_log_filename.ext"),
                content: "Some single line log content"),
        LogInfo(filepath: URL(filePath: "filepath/not-valid/long_content_log.ext"),
                content: .loremIpsum)
    ])
    
}

protocol ViewModelInterface {
    
    var state: ViewModelState { get }
    
    func closeLogs()
    func revealLogsInFinder()
    
}

@Observable
class ViewModel: ViewModelInterface {
    
    private(set) var state: ViewModelState = .idle
    
    func closeLogs() {
        state = .idle
    }
    
    func revealLogsInFinder() {
        guard !state.logs.isEmpty else {
            fatalError() // TODO: want to make sure we can't get here with no logs really
        }
        
        state
            .logs[0]
            .filepath
            .deletingLastPathComponent()
            .revealInFinder()
    }
    
}

extension ViewModel: FileDropDelegate.FileReceiver {
    
    func received(files: [URL]) {
        print("VM: oading logs: \(files)")
        state = .loading
        
        Task {
            var logs: [LogInfo] = []
            files.forEach {
                do {
                    let content = try String(contentsOf: $0,
                                             encoding: .utf8)
                    logs.append(LogInfo(filepath: $0,
                                        content: content))
                } catch {
                    print("ERROR: Failed to load \($0): \(error)") // TODO: show in UI
                }
            }
            
            // TODO: if zero logs then go to error state (with error describing any errors caught above
            
            Task { @MainActor in
                print("VM: \(logs.count) logs loaded")
                state = .logsLoaded(logs)
                print("VM: state set to loaded")
            }
        }
    }
    
    func received(error: FileDropDelegate.Error) {
        Task { @MainActor in
            print("Log extraction failed: \(error)")
            state = .error(error)
        }
    }
    
}
