//
//  StringExtension.swift
//  XCResultExtractor
//
//  Created by Chris Mash on 20/10/2024.
//

import Testing
import Foundation

extension String {
    
    init(assetPath: String,
         sourceLocation: SourceLocation = #_sourceLocation) throws {
        let path = URL.testAsset(path: assetPath, sourceLocation: sourceLocation)
        try self.init(contentsOf: path, encoding: .utf8)
    }
    
}
