//
//  LogView.swift
//  XCResultExtractorApp
//
//  Created by Chris Mash on 11/05/2025.
//

import SwiftUI

struct LogView: View {
    
    let content: String
    
    var body: some View {
        // TODO: show line numbers?
        // TODO: searchable (jump to specific lines, by regex?)
        // TODO: filterable (show/hide specific lines, by regex?)
        BetterTextEditor(text: .constant(content),
                         editable: false)
    }
    
    // MARK: Private
    private var lines: [Line] {
        // TODO: keep this or nah?
        // TODO: probably want to do this once in VM eh?
        content
            .components(separatedBy: "\n")
            .enumerated()
            .map {
                Line(number: $0.0 + 1,
                     content: $0.1)
            }
    }
    
}


#Preview("short") {
    LogView(content: "Some content")
}

#Preview("long") {
    LogView(content: .loremIpsum)
}
