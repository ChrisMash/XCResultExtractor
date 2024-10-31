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

    // MARK: extractGraph
    @Test func extractGraphReturnsGraphFromTestAppResults() async throws {
        let path = URL.testAsset(path: "TestApp.xcresult")
        let mockShell = MockShell()
        mockShell.executeOutput = "this is the graph"
        let mockFileHandler = MockFileHandler()
        let sut = XCResultTool(shell: mockShell,
                               fileHandler: mockFileHandler,
                               logger: MockLogger())
        let graph = try sut.extractGraph(from: path.path())
        #expect(graph == "this is the graph")
        // Graph write not requested
        #expect(mockFileHandler.writeStringIn == nil)
        #expect(mockFileHandler.writePathIn == nil)
    }
    
    @Test func extractGraphReturnsGraphAndWritesOutFromTestAppResults() async throws {
        let path = URL.testAsset(path: "TestApp.xcresult")
        let mockShell = MockShell()
        mockShell.executeOutput = "this is the graph"
        let mockFileHandler = MockFileHandler()
        let sut = XCResultTool(shell: mockShell,
                               fileHandler: mockFileHandler,
                               logger: MockLogger())
        let outputPath = URL.testAssetDir()
        let graph = try sut.extractGraph(from: path.path(),
                                         outputPath: outputPath)
        #expect(graph == "this is the graph")
        // Graph write requested
        #expect(mockFileHandler.writeStringIn == graph)
        #expect(mockFileHandler.writePathIn == outputPath.appending(path: "graph.txt"))
    }
    
    @Test func extractGraphThrowsErrorFromShell() async throws {
        let mockShell = MockShell()
        mockShell.executeErrorOut = TestError()
        let sut = XCResultTool(shell: mockShell,
                               fileHandler: MockFileHandler(),
                               logger: MockLogger())
        try expectThrows {
            try sut.extractGraph(from: "some path")
        } error: {
            if case let XCResultTool.GraphExtractError.xcResultToolError(rootError) = $0 {
                #expect(rootError is TestError)
            } else {
                #expect(Bool(false), "Unexpected error: \($0)")
            }
        }
    }
    
    @Test func extractGraphThrowsErrorForEmptyGraph() async throws {
        let mockShell = MockShell()
        mockShell.executeOutput = ""
        let sut = XCResultTool(shell: mockShell,
                               fileHandler: MockFileHandler(),
                               logger: MockLogger())
        
        try expectThrows {
            try sut.extractGraph(from: "some path")
        } error: {
            let extractError = try #require($0 as? XCResultTool.GraphExtractError)
            switch extractError {
            case .noOutput:
                #expect(Bool(true))
            default:
                #expect(Bool(false), "Unexpected error: \(extractError)")
            }
        }
    }
    
    @Test func extractGraphThrowsErrorForErrorOutput() async throws {
        let mockShell = MockShell()
        mockShell.executeOutput = "Error:"
        let sut = XCResultTool(shell: mockShell,
                               fileHandler: MockFileHandler(),
                               logger: MockLogger())
        try expectThrows {
            try sut.extractGraph(from: "some path")
        } error: {
            let extractError = try #require($0 as? XCResultTool.GraphExtractError)
            switch extractError {
            case .errorOutput("Error:"):
                #expect(Bool(true))
            default:
                #expect(Bool(false), "Unexpected error: \(extractError)")
            }
        }
    }
    
    @Test func extractGraphHandlesErrorFromGraphWrite() async throws {
        let path = URL.testAsset(path: "TestApp.xcresult")
        let mockShell = MockShell()
        mockShell.executeOutput = "this is the graph"
        let mockFileHandler = MockFileHandler()
        mockFileHandler.writeErrorOut = TestError()
        let sut = XCResultTool(shell: mockShell,
                               fileHandler: mockFileHandler,
                               logger: MockLogger())
        let graph = try sut.extractGraph(from: path.path(),
                                         outputPath: URL(fileURLWithPath: "output_path"))
        #expect(graph == "this is the graph")
        // Graph write requested
        #expect(mockFileHandler.writeStringIn == graph)
        #expect(mockFileHandler.writePathIn?.path() == "output_path/graph.txt")
    }
    
    // MARK: exportLogs
    @Test func exportLogsSucceeds() async throws {
        let mockShell = MockShell()
        mockShell.executeOutput = "Exported file with id X"
        let mockFileHandler = MockFileHandler()
        let sut = XCResultTool(shell: mockShell,
                               fileHandler: mockFileHandler,
                               logger: MockLogger())
        try sut.export(logs: [
            .init(name: "Log1", id: "id1"),
            .init(name: "Log2", id: "id2")
        ],
                       from: "path_to.xcresult",
                       to: "output_path")
        #expect(mockFileHandler.createDirPathIn == "output_path/tmp/")
        #expect(mockFileHandler.moveItemsSourceIn?.path() == "output_path/tmp/")
        #expect(mockFileHandler.moveItemsDestinationIn?.path() == "output_path/")
        #expect(mockFileHandler.removeItemPathIn?.path() == "output_path/tmp/")
    }
    
    @Test func exportLogsReportsCreateDirError() async throws {
        let mockFileHandler = MockFileHandler()
        let sut = XCResultTool(shell: MockShell(),
                               fileHandler: mockFileHandler,
                               logger: MockLogger())
        mockFileHandler.createDirErrorOut = TestError()
        try expectThrows {
            try sut.export(logs: [
                .init(name: "Log1", id: "id1"),
                .init(name: "Log2", id: "id2")
            ],
                           from: "path_to.xcresult",
                           to: "output_path")
        } error: {
            if case let XCResultTool.LogExportError.createOutputDirectoryFailed(rootError) = $0 {
                #expect(rootError is TestError)
            } else {
                #expect(Bool(false), "Unexpected error: \($0)")
            }
        }
        
        #expect(mockFileHandler.createDirPathIn == "output_path/tmp/")
    }
    
    @Test func exportZeroLogsReportsError() async throws {
        let sut = XCResultTool(shell: MockShell(),
                               fileHandler: MockFileHandler(),
                               logger: MockLogger())
        try expectThrows {
            try sut.export(logs: [],
                           from: "path_to.xcresult",
                           to: "output_path")
        } error: {
            let exportError = try #require($0 as? XCResultTool.LogExportError)
            switch exportError {
            case .noLogsProvided:
                #expect(Bool(true))
            default:
                #expect(Bool(false), "Unexpected error: \(exportError)")
            }
        }
    }
    
    // TODO: test export logs more (logging of failures)
    
}
