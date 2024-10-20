//
//  GraphParserTest.swift
//  XCResultExtractor
//
//  Created by Chris Mash on 20/10/2024.
//

import Testing
import Foundation
@testable import XCResultExtractor

struct GraphParserTests {

    @Test func testAppUITestGraphParsesCorrectly() async throws {
        let graph = try String(assetPath: "TestAppGraph.txt")
        let logs = try GraphParser.parseLogs(from: graph)
        #expect(logs.count == 2)
        #expect(logs[0].id == "0~0Hww-uYOGMF9bqddBMEah58BmmEwS_JfHxfWSLbpZt7Nli62Ewvd63aunSOpYrYCF4K8wADFPPOqQRw5qVRxHA==")
        #expect(logs[0].name == "TestAppUITests-com.chrismash.TestApp")
        #expect(logs[1].id == "0~6dJPkHeM01yyOjOgiC4dj4zI3xiZl6WAczFWYwwFHixOyegvKmX1_esi7JTZF4feg8FqKrjnrRAiny7zvcE3yg==")
        #expect(logs[1].name == "TestAppUITests")
    }
    
    @Test func graphWithoutStdOutputThrowsError() async throws {
        #expect(throws: GraphParser.ParseError.logFilenameNotFound) {
            try GraphParser.parseLogs(from: "not really a graph")
        }
    }
    
    @Test func graphWithoutTargetLogsThrowsError() async throws {
        #expect(throws: GraphParser.ParseError.noTargetsWithLogsFound) {
            try GraphParser.parseLogs(from: "StandardOutputAndStandardError")
        }
    }

}

extension String {
    
    init(assetPath: String,
         sourceLocation: SourceLocation = #_sourceLocation) throws {
        let path = URL(fileURLWithPath: sourceLocation._filePath)
            .deletingLastPathComponent()
            .appendingPathComponent("Assets/TestAppGraph.txt")
        try self.init(contentsOf: path, encoding: .utf8)
    }
    
}
