//
//  LogView.swift
//  XCResultExtractorApp
//
//  Created by Chris Mash on 11/05/2025.
//

import SwiftUI

struct LogView: View {
    
    let log: LogInfo
    
    var body: some View {
        ScrollView {
            // TODO: searchable (jump to specific lines, by regex?)
            // TODO: filterable (show/hide specific lines, by regex?)

            VStack(alignment: .leading,
                   spacing: 0) {
                ForEach(lines) {
                    LineView(line: $0)
                }
            }
            .multilineTextAlignment(.leading)
            .textSelection(.enabled) // TODO: only works within a line
            .frame(maxWidth: .infinity,
                   maxHeight: .infinity,
                   alignment: .leading)
            .padding()
        }
    }
    
    // MARK: Private
    private var lines: [Line] {
        // TODO: probably want to do this once in VM eh?
        log
            .content
            .components(separatedBy: "\n")
            .enumerated()
            .map {
                Line(number: $0.0 + 1,
                     content: $0.1)
            }
    }
    
}


#Preview("short") {
    LogView(log: LogInfo(filepath: URL(filePath: "filepath/not-valid.txt"),
                         content: "Some content"))
}

#Preview("long") {
    LogView(log: LogInfo(filepath: URL(filePath: "filepath/not-valid.txt"),
                         content: .loremIpsum))
}
