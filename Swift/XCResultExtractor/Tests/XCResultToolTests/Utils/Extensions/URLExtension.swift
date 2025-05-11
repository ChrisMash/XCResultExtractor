//
//  URLExtension.swift
//  XCResultExtractor
//
//  Created by Chris Mash on 20/10/2024.
//

import Testing
import Foundation

extension URL {
    
    static func testAssetDir(sourceLocation: SourceLocation = #_sourceLocation) -> URL {
        URL(fileURLWithPath: sourceLocation._filePath)
            .deletingLastPathComponent()
            .appending(path: "Assets",
                       directoryHint: .isDirectory)
    }
    
    static func testAsset(path: String,
                          sourceLocation: SourceLocation = #_sourceLocation) -> URL {
        guard testAssets.contains(where: { $0 == path }) else {
            fatalError("Trying to load an unknown test asset")
        }
        
        return URL.testAssetDir(sourceLocation: sourceLocation)
            .appending(path: path)
    }
    
}
