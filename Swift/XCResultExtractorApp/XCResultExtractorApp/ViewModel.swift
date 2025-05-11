//
//  ViewModel.swift
//  XCResultExtractorApp
//
//  Created by Chris Mash on 11/05/2025.
//

import Foundation

struct LogInfo: Identifiable {
    
    let id = UUID()
    let filename: String
    let content: String
    
}

protocol ViewModelInterface {
    
    var logs: [LogInfo] { get }
    
}

@Observable
class ViewModel: ViewModelInterface {
    
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
