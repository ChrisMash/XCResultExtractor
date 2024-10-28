//
//  XCResultExtractor.swift
//  XCResultExtractor
//
//  Created by Chris Mash 2024.
//

import Foundation
import ArgumentParser

// TODO: usage example says the executable is xc-result-extractor but it's actually XCResultExtractor?
// TODO: shell script to test the actual exe (unless xcode gives an alternative)
// TODO: catch all errors and wrap them to know what step failed?
// TODO: loads of comments
// TODO: consistent URL/String for paths?
// TODO: rename TestApp to ExampleApp
// TODO: check for TODOs in testapp

@main
struct XCResultExtractor: ParsableCommand {
    
    @Argument(help: "The .xcresult bundle to parse")
    var xcResultPath: String
    
    @Argument(help: "[Optional] Path to write output to, default to the same directory that contains the .xcresult")
    var outputPath: String?
    
    mutating func run() throws {
        try LogExtractor.extractLogs(xcResultPath: xcResultPath,
                                              outputPath: outputPath)
    }
    
}
