//
//  ContentView.swift
//  XCResultExtractorApp
//
//  Created by Chris Mash on 11/05/2025.
//

import SwiftUI

struct ContentView: View {
    
    let viewModel: ViewModel
    
    var body: some View {
        if viewModel.logs.isEmpty {
            VStack(spacing: 10) {
                Image(systemName: "document.badge.plus")
                    .imageScale(.large)
                    .font(.title)
                Text("Drag an .xcresult file here!")
                    .font(.headline)
            }
            // TODO: expand to fill window so can be dropped anywhere
            // TODO: do an openFileDialog too?
            // TODO: how to load new xcresult?
        } else {
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(viewModel.logs) {
                        Text($0.filename)
                            .bold()
                        Divider()
                        Text($0.content)
                            .multilineTextAlignment(.leading)
                        Divider()
                    }
                }
            }
        }
    }
    
}

#Preview {
    ContentView(viewModel: ViewModel())
}
