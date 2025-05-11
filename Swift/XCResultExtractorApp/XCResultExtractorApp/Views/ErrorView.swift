//
//  ErrorView.swift
//  XCResultExtractorApp
//
//  Created by Chris Mash on 11/05/2025.
//

import SwiftUI

struct ErrorView: View {
    
    let error: Error
    
    var body: some View {
        Text("Failed to load logs: \(error)")
            .padding(8)
            .background(.red)
    }
    
}

#Preview {
    ErrorView(error: FileDropDelegate.Error.itemLoadFailed(NSError(domain: "Domain",
                                                                   code: 0)))
}
