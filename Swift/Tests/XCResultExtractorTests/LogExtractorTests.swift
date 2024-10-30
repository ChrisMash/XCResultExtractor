//
//  XCResultExtractorTests.swift
//  XCResultExtractor
//
//  Created by Chris Mash on 20/10/2024.
//

import Testing
import Foundation
@testable import XCResultExtractor

struct LogExtractorTests {

    @Test func extractsLogsExtractsLogsFromTestAppXCResult() async throws {
        let mockXCResultTool = MockXCResultTool()
        mockXCResultTool.extractGraphOut = try String(testAssetPath: "TestAppGraph.txt")
        let mockFileHandler = MockFileHandler()
        try LogExtractor.extractLogs(xcResultPath: URL.testAsset(path: "TestApp.xcresult").path(),
                                              outputPath: nil,
                                              xcResultTool: mockXCResultTool,
                                              shell: MockShell(),
                                              fileHandler: mockFileHandler)
    }
    
    // TODO: test dir creation throwing error
    // TODO: test optional output path
    // TODO: test graph extract error
    // TODO: test graph parse error
    // TODO: test log export error
    // TODO: test graph output as expected?

}
