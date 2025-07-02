//
//  ViewModel.swift
//  XCResultExtractorApp
//
//  Created by Chris Mash on 11/05/2025.
//

import Foundation
import XCResultTool

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
    
    enum LogsError: Error {
        case notXCResult(URL)
        case noLogs(String)
        case logExtractionFailed(Error)
    }
    
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
    
    func received(url: URL) {
        guard Thread.isMainThread else { fatalError() }
        
        guard url.lastPathComponent.hasSuffix(".xcresult") else {
            state = .error(LogsError.notXCResult(url))
            return
        }
        
        print("loading: \(url)")
        state = .loading
        
        Task {
            let shell = Shell()
            let fileHandler = FileHandler()
            let logger = Logger()
            let extractor = LogExtractor(xcResultTool: XCResultTool(shell: shell,
                                                                    fileHandler: fileHandler,
                                                                    logger: logger),
                                         shell: shell,
                                         graphParser: GraphParser(logger: logger),
                                         fileHandler: fileHandler,
                                         logger: logger)
            let outputPath = URL.temporaryDirectory.appendingPathComponent("export",
                                                                           conformingTo: .fileURL)
            // TODO: clear outputPath before exporting?
            
            do {
                try extractor.extractLogs(xcResultPath: url.path(),
                                          outputPath: outputPath.path()) // todo: get this to return the log paths. could be more things in there
                
                guard let enumerator = FileManager.default.enumerator(atPath: outputPath.path()) else {
                    print("ERROR: Failed to enumerate directory \(outputPath)")
                    return
                }
                
                var files: [URL] = []
                enumerator.forEach {
                    guard let filename = $0 as? String else {
                        print("ERROR: unexpected filename type: \($0)")
                        return
                    }
                    
                    if filename != "graph.txt" {
                        files.append(outputPath.appendingPathComponent(filename,
                                                                       conformingTo: .fileURL))
                    }
                }
                
                var logs: [LogInfo] = []
                var errors: [String] = []
                files.forEach {
                    do {
                        let content = try String(contentsOf: $0,
                                                 encoding: .utf8)
                        logs.append(LogInfo(filepath: $0,
                                            content: content))
                    } catch {
                        print("ERROR: Failed to load \($0): \(error)")
                        errors.append("Failed to load \($0): \(error)")
                    }
                }
                
                Task { @MainActor in
                    print("VM: \(logs.count) logs loaded")
                    // TODO: what if one log failed and another didn't?
                    // could have a logs console or use the error as the log content?
                    if logs.isEmpty {
                        state = .error(LogsError.noLogs(errors.joined(separator: "\n")))
                    } else {
                        state = .logsLoaded(logs)
                    }
                }
            } catch {
                print("ERROR: Failed to extract logs: \(error)")
                Task { @MainActor in
                    state = .error(LogsError.logExtractionFailed(error))
                }
            }
        }
    }
    
    func received(error: FileDropDelegate.FileError) {
        guard Thread.isMainThread else { fatalError() }
        
        print("Log extraction failed: \(error)")
        state = .error(error)
    }
    
}
