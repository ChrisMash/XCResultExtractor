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
            // TODO: show line numbers?
            // TODO: searchable (jump to specific lines, by regex?)
            // TODO: filterable (show/hide specific lines, by regex?)
            TextEditor(text: .constant(log.content))
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
                .padding()
                .lineSpacing(4)
        }
    }
    
    // MARK: Private
    private var lines: [Line] {
        // TODO: keep this or nah?
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
