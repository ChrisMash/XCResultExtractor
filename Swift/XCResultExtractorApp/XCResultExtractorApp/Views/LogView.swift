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
            Text(log.content)
                .multilineTextAlignment(.leading)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity,
                       maxHeight: .infinity,
                       alignment: .leading)
                .padding()
        }
    }
    
}


#Preview {
    LogView(log: LogInfo(filepath: URL(filePath: "filepath/not-valid.txt"),
                         content: "Some content"))
}
