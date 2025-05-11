//
//  XCResultExtractorTests.swift
//  XCResultExtractor
//
//  Created by Chris Mash on 30/10/2024.
//

import Testing
@testable import XCResultExtractor

struct XCResultExtractorTests {

    @Test func basicParseWorksCorrectly() async throws {
        let extractor = try #require(XCResultExtractor.parseAsRoot([
            "path/to/the.xcresult",
        ]) as? XCResultExtractor)
        #expect(extractor.xcResultPath == "path/to/the.xcresult")
        #expect(extractor.outputPath == nil)
    }
    
    @Test func optionalOutputPathParsesCorrectly() async throws {
        let extractor = try #require(XCResultExtractor.parseAsRoot([
            "path/to/the.xcresult",
            "path/to/output/"
        ]) as? XCResultExtractor)
        #expect(extractor.xcResultPath == "path/to/the.xcresult")
        #expect(extractor.outputPath == "path/to/output/")
    }

}
