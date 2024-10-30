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
        let sut = LogExtractor(xcResultTool: mockXCResultTool,
                               shell: MockShell(),
                               graphParser: mockGraphParser,
                               fileHandler: MockFileHandler(),
                               logger: MockLogger())
        try sut.extractLogs(xcResultPath: URL.testAsset(path: "TestApp.xcresult").path(),
                            outputPath: nil)
        #expect(mockGraphParser.parseGraphIn == "some graph")
    }
    
    @Test func extractsLogsExtractsLogsFromTestAppXCResultAndCreatesOptionalOutputPath() async throws {
        let mockXCResultTool = MockXCResultTool()
        mockXCResultTool.extractGraphOut = "some graph"
        let mockGraphParser = MockGraphParser()
        mockGraphParser.parseLogsOut = []
        let mockFileHandler = MockFileHandler()
        let sut = LogExtractor(xcResultTool: mockXCResultTool,
                               shell: MockShell(),
                               graphParser: mockGraphParser,
                               fileHandler: mockFileHandler,
                               logger: MockLogger())
        try sut.extractLogs(xcResultPath: URL.testAsset(path: "TestApp.xcresult").path(),
                            outputPath: "output_path")
        #expect(mockGraphParser.parseGraphIn == "some graph")
        #expect(mockFileHandler.createDirPathIn == "output_path")
        // TODO: test output path is used
    }
    
    @Test func extractsLogsReportsErrorCreatingOptionalOutputPath() async throws {
        let mockXCResultTool = MockXCResultTool()
        mockXCResultTool.extractGraphOut = "some graph"
        let mockFileHandler = MockFileHandler()
        mockFileHandler.createDirErrorOut = TestError()
        let sut = LogExtractor(xcResultTool: mockXCResultTool,
                               shell: MockShell(),
                               graphParser: MockGraphParser(),
                               fileHandler: mockFileHandler,
                               logger: MockLogger())
        try expectThrows {
            try sut.extractLogs(xcResultPath: URL.testAsset(path: "TestApp.xcresult").path(),
                                outputPath: "output_path")
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
        let sut = LogExtractor(xcResultTool: mockXCResultTool,
                               shell: MockShell(),
                               graphParser: MockGraphParser(),
                               fileHandler: MockFileHandler(),
                               logger: MockLogger())
        try expectThrows {
            try sut.extractLogs(xcResultPath: URL.testAsset(path: "TestApp.xcresult").path(),
                                outputPath: nil)
        } error: {
            #expect($0 is TestError)
        }
    }
    
    @Test func extractsLogsReportsErrorParsingGraph() async throws {
        let mockXCResultTool = MockXCResultTool()
        mockXCResultTool.extractGraphOut = "some graph"
        let mockGraphParser = MockGraphParser()
        mockGraphParser.parseErrorOut = TestError()
        let sut = LogExtractor(xcResultTool: mockXCResultTool,
                               shell: MockShell(),
                               graphParser: mockGraphParser,
                               fileHandler: MockFileHandler(),
                               logger: MockLogger())
        try expectThrows {
            try sut.extractLogs(xcResultPath: URL.testAsset(path: "TestApp.xcresult").path(),
                                outputPath: nil)
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
        let sut = LogExtractor(xcResultTool: mockXCResultTool,
                               shell: MockShell(),
                               graphParser: mockGraphParser,
                               fileHandler: MockFileHandler(),
                               logger: MockLogger())
        try expectThrows {
            try sut.extractLogs(xcResultPath: URL.testAsset(path: "TestApp.xcresult").path(),
                                outputPath: nil)
        } error: {
            #expect($0 is TestError)
        }
    }
    
    // TODO: test graph output as expected?

}
