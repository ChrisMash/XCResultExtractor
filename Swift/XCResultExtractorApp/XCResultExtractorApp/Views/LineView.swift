//
//  LineView.swift
//  XCResultExtractorApp
//
//  Created by Chris Mash on 12/05/2025.
//

import SwiftUI

struct Line: Identifiable {
    
    let id = UUID()
    let number: Int
    let content: String
    
}

struct LineView: View {
    
    let line: Line
    
    var body: some View {
        HStack {
            VStack {
                Text(String(line.number))
                    //.font(.caption)
                    .foregroundColor(.secondary)
                    .monospacedDigit() // TODO: want it prefixed with 0s? or at least spaces.
                    
                
                Spacer() // TODO: breaks single line
            }
            .frame(maxHeight: .infinity)
            .background(Color.secondary.opacity(0.1))
            
            Text(line.content)
        }
        .fixedSize(horizontal: false,
                   vertical: true)
    }
    
}

#Preview {
    VStack(alignment: .leading,
           spacing: 0) {
        LineView(line: Line(number: 1,
                            content: "short line"))
        LineView(line: Line(number: 100,
                            content: "high numbered line"))
        LineView(line: Line(number: 1,
                            content: "longer line that will then go onto multiple lines so we can see how that looks and make sure it actually looks good otherwise we'll have problems"))
        Spacer()
    }
}
