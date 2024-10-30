//
//  XCResultExtractor.swift
//  XCResultExtractor
//
//  Created by Chris Mash 2024.
//

import Foundation
import ArgumentParser

// TODO: usage example says the executable is xc-result-extractor but it's actually XCResultExtractor?
// TODO: loads of comments
// TODO: consistent URL/String for paths?
// TODO: rename TestApp to ExampleApp
// TODO: check for TODOs in testapp
// TODO: make sure readme explains how to get the different test Assets generated

@main
struct XCResultExtractor: ParsableCommand {
    
    @Argument(help: "The .xcresult bundle to parse")
    var xcResultPath: String
    
    @Argument(help: "[Optional] Path to write output to, default to the same directory that contains the .xcresult")
    var outputPath: String?
    
    mutating func run() throws {
        let logger = Logger()
        let shell = Shell()
        let fileHandler = FileHandler()
        let extractor = LogExtractor(xcResultTool: XCResultTool(shell: shell,
                                                                fileHandler: fileHandler,
                                                                logger: logger),
                                     shell: shell,
                                     graphParser: GraphParser(logger: logger),
                                     fileHandler: fileHandler,
                                     logger: logger)
        try extractor.extractLogs(xcResultPath: xcResultPath,
                                  outputPath: outputPath)
    }
    
}
