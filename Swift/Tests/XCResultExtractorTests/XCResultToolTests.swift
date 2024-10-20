//
//  XCResultToolTests.swift
//  XCResultExtractor
//
//  Created by Chris Mash on 20/10/2024.
//

import Testing
import Foundation
@testable import XCResultExtractor

struct XCResultToolTests {

    @Test func exportGraphReturnsGraphFromTestAppResults() async throws {
        let path = URL.testAsset(path: "TestApp.xcresult")
        let graph = try XCResultTool.extractGraph(from: path.path())
        #expect(!graph.isEmpty)
    }
    
    @Test func exportGraphThrowsErrorForBadPath() async throws {
        #expect(throws: XCResultTool.ExtractError.errorOutput("""
            Error: File or directory doesn't exist at path: not_a_path/.
            Usage: xcresulttool <subcommand>
              See \'xcresulttool --help\' for more information.
            
            """)) {
            try XCResultTool.extractGraph(from: "not_a_path")
        }
    }
    
    // TODO: test failure to write graph.txt

}
