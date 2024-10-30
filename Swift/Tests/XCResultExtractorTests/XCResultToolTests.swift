//
//  XCResultToolTests.swift
//  XCResultExtractor
//
//  Created by Chris Mash on 20/10/2024.
//

import Testing
import Foundation
@testable import XCResultExtractor

struct TestError: Error {}

struct XCResultToolTests {

    // MARK: extractGraph
    @Test func extractGraphReturnsGraphFromTestAppResults() async throws {
        let sut = XCResultTool()
        let path = URL.testAsset(path: "TestApp.xcresult")
        let mockShell = MockShell()
        mockShell.executeOutput = "this is the graph"
        let mockFileHandler = MockFileHandler()
        let graph = try sut.extractGraph(from: path.path(),
                                         shell: mockShell,
                                         fileHandler: mockFileHandler)
        #expect(graph == "this is the graph")
        // Graph write not requested
        #expect(mockFileHandler.writeStringIn == nil)
        #expect(mockFileHandler.writePathIn == nil)
    }
    
    @Test func extractGraphReturnsGraphAndWritesOutFromTestAppResults() async throws {
        let sut = XCResultTool()
        let path = URL.testAsset(path: "TestApp.xcresult")
        let mockShell = MockShell()
        mockShell.executeOutput = "this is the graph"
        let mockFileHandler = MockFileHandler()
        let outputPath = URL.testAssetDir()
        let graph = try sut.extractGraph(from: path.path(),
                                         outputPath: outputPath,
                                         shell: mockShell,
                                         fileHandler: mockFileHandler)
        #expect(graph == "this is the graph")
        // Graph write requested
        #expect(mockFileHandler.writeStringIn == graph)
        #expect(mockFileHandler.writePathIn == outputPath.appending(path: "graph.txt"))
    }
    
    @Test func extractGraphThrowsErrorFromShell() async throws {
        let sut = XCResultTool()
        let mockShell = MockShell()
        mockShell.executeErrorOut = TestError()
        
        try expectThrows {
            try sut.extractGraph(from: "some path",
                                 shell: mockShell,
                                 fileHandler: MockFileHandler())
        } error: {
            if case let ExtractError.xcResultToolError(rootError) = $0 {
                #expect(rootError is TestError)
            } else {
                #expect(Bool(false), "Unexpected error: \($0)")
            }
        }
    }
    
    @Test func extractGraphThrowsErrorForEmptyGraph() async throws {
        let sut = XCResultTool()
        let mockShell = MockShell()
        mockShell.executeOutput = ""
        
        try expectThrows {
            try sut.extractGraph(from: "some path",
                                 shell: mockShell,
                                 fileHandler: MockFileHandler())
        } error: {
            let extractError = try #require($0 as? ExtractError)
            switch extractError {
            case .noOutput:
                #expect(Bool(true))
            default:
                #expect(Bool(false), "Unexpected error: \(extractError)")
            }
        }
    }
    
    @Test func extractGraphThrowsErrorForErrorOutput() async throws {
        let sut = XCResultTool()
        let mockShell = MockShell()
        mockShell.executeOutput = "Error:"
        
        try expectThrows {
            try sut.extractGraph(from: "some path",
                                 shell: mockShell,
                                 fileHandler: MockFileHandler())
        } error: {
            let extractError = try #require($0 as? ExtractError)
            switch extractError {
            case .errorOutput("Error:"):
                #expect(Bool(true))
            default:
                #expect(Bool(false), "Unexpected error: \(extractError)")
            }
        }
    }
    
    @Test func extractGraphHandlesErrorFromGraphWrite() async throws {
        let sut = XCResultTool()
        let path = URL.testAsset(path: "TestApp.xcresult")
        let mockShell = MockShell()
        mockShell.executeOutput = "this is the graph"
        let mockFileHandler = MockFileHandler()
        mockFileHandler.writeErrorOut = TestError()
        let graph = try sut.extractGraph(from: path.path(),
                                         outputPath: URL(fileURLWithPath: "output_path"),
                                         shell: mockShell,
                                         fileHandler: mockFileHandler)
        #expect(graph == "this is the graph")
        // Graph write requested
        #expect(mockFileHandler.writeStringIn == graph)
        #expect(mockFileHandler.writePathIn?.path() == "output_path/graph.txt")
    }
    
    // MARK: exportLogs
    @Test func exportLogsSucceeds() async throws {
        let sut = XCResultTool()
        let mockShell = MockShell()
        mockShell.executeOutput = "Exported file with id X"
        let mockFileHandler = MockFileHandler()
        try sut.export(logs: [
            .init(name: "Log1", id: "id1"),
            .init(name: "Log2", id: "id2")
        ],
                       from: "path_to.xcresult",
                       to: "output_path",
                       shell: mockShell,
                       fileHandler: mockFileHandler)
        #expect(mockFileHandler.createDirPathIn == "output_path/tmp/")
        #expect(mockFileHandler.moveItemsSourceIn?.path() == "output_path/tmp/")
        #expect(mockFileHandler.moveItemsDestinationIn?.path() == "output_path/")
        #expect(mockFileHandler.removeItemPathIn?.path() == "output_path/tmp/")
    }
    
    @Test func exportLogsReportsCreateDirError() async throws {
        let sut = XCResultTool()
        let mockFileHandler = MockFileHandler()
        mockFileHandler.createDirErrorOut = TestError()
        try expectThrows {
            try sut.export(logs: [
                .init(name: "Log1", id: "id1"),
                .init(name: "Log2", id: "id2")
            ],
                           from: "path_to.xcresult",
                           to: "output_path",
                           shell: MockShell(),
                           fileHandler: mockFileHandler)
        } error: {
            if case let ExportError.createOutputDirectoryFailed(rootError) = $0 {
                #expect(rootError is TestError)
            } else {
                #expect(Bool(false), "Unexpected error: \($0)")
            }
        }
        
        #expect(mockFileHandler.createDirPathIn == "output_path/tmp/")
    }
    
    @Test func exportZeroLogsReportsError() async throws {
        let sut = XCResultTool()
        try expectThrows {
            try sut.export(logs: [],
                           from: "path_to.xcresult",
                           to: "output_path",
                           shell: MockShell(),
                           fileHandler: MockFileHandler())
        } error: {
            let exportError = try #require($0 as? ExportError)
            switch exportError {
            case .noLogsProvided:
                #expect(Bool(true))
            default:
                #expect(Bool(false), "Unexpected error: \(exportError)")
            }
        }
    }
    
    // TODO: test export logs more (logging of failures)
    
    // MARK: Private
    private func expectThrows(_ closure: () throws -> Any,
                              error errorMatcher: (Error) throws -> Void,
                              sourceLocation: SourceLocation = #_sourceLocation) throws {
//        #expect(throws: XCResultTool.ExtractError.xcResultToolError(TestError())) {
//            try sut.extractGraph(from: "some path",
//                                 shell: mockShell,
//                                 fileHandler: MockFileHandler())
//        }
        
        // Above doesn't match properly, so doing it this way!
        do {
            let _ = try closure()
            #expect(Bool(false),
                    "Expected error to be thrown, but wasn't",
                    sourceLocation: sourceLocation)
        } catch {
            try errorMatcher(error)
        }
    }
    
}
