//
//  URLExtension.swift
//  XCResultExtractor
//
//  Created by Chris Mash on 20/10/2024.
//

import Testing
import Foundation

extension URL {
    
    static func testsDir(sourceLocation: SourceLocation = #_sourceLocation) -> URL {
        URL(fileURLWithPath: sourceLocation._filePath)
            .deletingLastPathComponent()
    }
    
}
