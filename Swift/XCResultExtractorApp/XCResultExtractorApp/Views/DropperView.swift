//
//  DropperView.swift
//  XCResultExtractorApp
//
//  Created by Chris Mash on 11/05/2025.
//

import SwiftUI

struct DropperView: View {
    
    let delegate: DropDelegate
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "document.badge.plus")
                .imageScale(.large)
                .font(.largeTitle)
            Text("Drag an .xcresult file here!")
                .font(.headline)
        }
        .frame(maxWidth: .infinity,
               maxHeight: .infinity)
        .onDrop(of: [.fileURL],
                delegate: delegate)
        // TODO: do an openFileDialog too?
    }
    
}

#Preview {
    DropperView(delegate: MockDropDelegate())
}

struct MockDropDelegate: DropDelegate {
    func performDrop(info: DropInfo) -> Bool { true }
}
