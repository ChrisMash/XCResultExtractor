//
//  URLExt.swift
//  XCResultExtractorApp
//
//  Created by Chris Mash on 11/05/2025.
//

import AppKit

// https://stackoverflow.com/a/59465302
extension URL {

    /// IMPORTANT: this code return false even if file or directory does not exist(!!!)
    var isDirectory: Bool {
        hasDirectoryPath
    }
    
    func revealInFinder() {
        if isDirectory {
            NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: path)
        } else {
            NSWorkspace.shared.activateFileViewerSelecting([self])
        }
    }

}
