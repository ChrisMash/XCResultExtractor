//
//  XCResultExtractorTests.swift
//  XCResultExtractor
//
//  Created by Chris Mash on 20/10/2024.
//

import Testing
import Foundation
@testable import XCResultExtractor

struct XCResultExtractorTests {

    @Test func extractsLogsExtractsLogsFromTestAppXCResult() async throws {
        let mockXCResultTool = MockXCResultTool()
        mockXCResultTool.extractGraphOut = try String(testAssetPath: "TestAppGraph.txt")
        let mockFileHandler = MockFileHandler()
        try XCResultExtractorReal.extractLogs(xcResultPath: URL.testAsset(path: "TestApp.xcresult").path(),
                                              outputPath: nil,
                                              xcResultTool: mockXCResultTool,
                                              shell: MockShell(),
                                              fileHandler: mockFileHandler)
        // TODO: errors exporting are logged but not particularly discernable in tests? so this passes even if the export didn't work
    }
    
    // TODO: test dir creation throwing error
    // TODO: test optional output path
    // TODO: test graph output as expected?
    // TODO: test logs?

}
