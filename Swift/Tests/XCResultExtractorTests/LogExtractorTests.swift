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
        mockXCResultTool.extractGraphOut = "some graph"
        let mockGraphParser = MockGraphParser()
        mockGraphParser.parseLogsOut = []
        try LogExtractor.extractLogs(xcResultPath: URL.testAsset(path: "TestApp.xcresult").path(),
                                     outputPath: nil,
                                     xcResultTool: mockXCResultTool,
                                     shell: MockShell(),
                                     graphParser: mockGraphParser,
                                     fileHandler: MockFileHandler())
        #expect(mockGraphParser.parseGraphIn == "some graph")
    }
    
    @Test func extractsLogsExtractsLogsFromTestAppXCResultAndCreatesOptionalOutputPath() async throws {
        let mockXCResultTool = MockXCResultTool()
        mockXCResultTool.extractGraphOut = "some graph"
        let mockGraphParser = MockGraphParser()
        mockGraphParser.parseLogsOut = []
        let mockFileHandler = MockFileHandler()
        try LogExtractor.extractLogs(xcResultPath: URL.testAsset(path: "TestApp.xcresult").path(),
                                     outputPath: "output_path",
                                     xcResultTool: mockXCResultTool,
                                     shell: MockShell(),
                                     graphParser: mockGraphParser,
                                     fileHandler: mockFileHandler)
        #expect(mockGraphParser.parseGraphIn == "some graph")
        #expect(mockFileHandler.createDirPathIn == "output_path")
        // TODO: test output path is used
    }
    
    @Test func extractsLogsReportsErrorCreatingOptionalOutputPath() async throws {
        let mockXCResultTool = MockXCResultTool()
        mockXCResultTool.extractGraphOut = "some graph"
        let mockFileHandler = MockFileHandler()
        mockFileHandler.createDirErrorOut = TestError()
        try expectThrows {
            try LogExtractor.extractLogs(xcResultPath: URL.testAsset(path: "TestApp.xcresult").path(),
                                         outputPath: "output_path",
                                         xcResultTool: mockXCResultTool,
                                         shell: MockShell(),
                                         graphParser: MockGraphParser(),
                                         fileHandler: mockFileHandler)
        } error: {
            if case let LogExtractError.createOutputDirectoryFailed(rootError) = $0 {
                #expect(rootError is TestError)
            } else {
                #expect(Bool(false), "Unexpected error: \($0)")
            }
        }
    }
    
    @Test func extractsLogsReportsErrorExtractingGraph() async throws {
        let mockXCResultTool = MockXCResultTool()
        mockXCResultTool.extractErrorOut = TestError()
        try expectThrows {
            try LogExtractor.extractLogs(xcResultPath: URL.testAsset(path: "TestApp.xcresult").path(),
                                         outputPath: nil,
                                         xcResultTool: mockXCResultTool,
                                         shell: MockShell(),
                                         graphParser: MockGraphParser(),
                                         fileHandler: MockFileHandler())
        } error: {
            #expect($0 is TestError)
        }
    }
    
    @Test func extractsLogsReportsErrorParsingGraph() async throws {
        let mockXCResultTool = MockXCResultTool()
        mockXCResultTool.extractGraphOut = "some graph"
        let mockGraphParser = MockGraphParser()
        mockGraphParser.parseErrorOut = TestError()
        try expectThrows {
            try LogExtractor.extractLogs(xcResultPath: URL.testAsset(path: "TestApp.xcresult").path(),
                                         outputPath: nil,
                                         xcResultTool: mockXCResultTool,
                                         shell: MockShell(),
                                         graphParser: mockGraphParser,
                                         fileHandler: MockFileHandler())
        } error: {
            #expect($0 is TestError)
        }
    }
    
    @Test func extractLogsReportsErrorExporting() async throws {
        let mockXCResultTool = MockXCResultTool()
        mockXCResultTool.extractGraphOut = "some graph"
        mockXCResultTool.exportErrorOut = TestError()
        let mockGraphParser = MockGraphParser()
        mockGraphParser.parseLogsOut = []
        try expectThrows {
            try LogExtractor.extractLogs(xcResultPath: URL.testAsset(path: "TestApp.xcresult").path(),
                                         outputPath: nil,
                                         xcResultTool: mockXCResultTool,
                                         shell: MockShell(),
                                         graphParser: mockGraphParser,
                                         fileHandler: MockFileHandler())
        } error: {
            #expect($0 is TestError)
        }
    }
    
    // TODO: test graph output as expected?

}
