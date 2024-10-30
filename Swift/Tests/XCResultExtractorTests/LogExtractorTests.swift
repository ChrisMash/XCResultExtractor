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
        try LogExtractor.extractLogs(xcResultPath: URL.testAsset(path: "TestApp.xcresult").path(),
                                              outputPath: nil,
                                              xcResultTool: mockXCResultTool,
                                              shell: MockShell(),
                                              fileHandler: MockFileHandler())
    }
    
    @Test func extractsLogsExtractsLogsFromTestAppXCResultAndCreatesOptionalOutputPath() async throws {
        let mockXCResultTool = MockXCResultTool()
        mockXCResultTool.extractGraphOut = try String(testAssetPath: "TestAppGraph.txt")
        let mockFileHandler = MockFileHandler()
        try LogExtractor.extractLogs(xcResultPath: URL.testAsset(path: "TestApp.xcresult").path(),
                                              outputPath: "output_path",
                                              xcResultTool: mockXCResultTool,
                                              shell: MockShell(),
                                              fileHandler: mockFileHandler)
        #expect(mockFileHandler.createDirPathIn == "output_path")
        // TODO: test output path is used
    }
    
    @Test func extractsLogsReportsErrorCreatingOptionalOutputPath() async throws {
        let mockXCResultTool = MockXCResultTool()
        mockXCResultTool.extractGraphOut = try String(testAssetPath: "TestAppGraph.txt")
        let mockFileHandler = MockFileHandler()
        mockFileHandler.createDirErrorOut = TestError()
        try expectThrows {
            try LogExtractor.extractLogs(xcResultPath: URL.testAsset(path: "TestApp.xcresult").path(),
                                         outputPath: "output_path",
                                         xcResultTool: mockXCResultTool,
                                         shell: MockShell(),
                                         fileHandler: mockFileHandler)
        } error: {
            if case let LogExtractError.createOutputDirectoryFailed(rootError) = $0 {
                #expect(rootError is TestError)
            } else {
                #expect(Bool(false), "Unexpected error: \($0)")
            }
        }
    }
    
    // TODO: test graph extract error
    // TODO: test graph parse error
    // TODO: test log export error
    // TODO: test graph output as expected?

}
