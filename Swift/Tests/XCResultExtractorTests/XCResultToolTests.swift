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
    }
    
    @Test func extractGraphThrowsErrorFromShell() async throws {
        let sut = XCResultTool()
        let mockShell = MockShell()
        mockShell.executeErrorOut = TestError()
//        #expect(throws: XCResultTool.ExtractError.xcResultToolError(TestError())) {
//            try sut.extractGraph(from: "some path",
//                                 shell: mockShell,
//                                 fileHandler: MockFileHandler())
//        }
        // Above doesn't match properly
        do {
            let _ = try sut.extractGraph(from: "some path",
                                         shell: mockShell,
                                         fileHandler: MockFileHandler())
            #expect(Bool(false), "Didn't expect to get here")
        } catch {
            if case let XCResultTool.ExtractError.xcResultToolError(rootError) = error {
                #expect(rootError is TestError)
            } else {
                #expect(Bool(false), "Unexpected error: \(error)")
            }
        } // TODO: wrap into a function?
    }
    
    // TODO: check graph gets written with file handler, if output path specified
    // TODO: test failure to write graph.txt
    
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
    
    // TODO: test passing zero logs to export... what should happen? throw error straight away?
    // TODO: test export logs more
    
}
