//
//  IntegrationTests.swift
//  XCResultExtractor
//
//  Created by Chris Mash on 21/10/2024.
//

import Testing
import Foundation
@testable import XCResultExtractor

struct IntegrationTests {

    @Test func extractsLogsExtractsLogsFromTestAppXCResult() async throws {
        try XCResultExtractorReal.extractLogs(xcResultPath: URL.testAsset(path: "TestApp.xcresult").path(),
                                              outputPath: nil)
        let fm = FileManager.default
        // Check tmp directory not present
        let testAssetsDir = URL.testAssetDir()
        #expect(!fm.fileExists(atPath: testAssetsDir.appending(path: "tmp",
                                                               directoryHint: .isDirectory).path()))
        // Check expected files present (and delete them)
        let expectedFiles = [
            (testAssetsDir.appending(path: "graph.txt",
                                     directoryHint: .notDirectory).path(),
             "StandardOutputAndStandardError"),
            (testAssetsDir.appending(path: "TestAppUITests.txt",
                                     directoryHint: .notDirectory).path(),
             "TestAppUITests-Runner"),
            (testAssetsDir.appending(path: "TestAppUITests-com.chrismash.TestApp.txt",
                                     directoryHint: .notDirectory).path(),
             "App initialised")
        ]
        
        for (path, contents) in expectedFiles {
            #expect(fm.fileExists(atPath: path))
            let file = try String(contentsOf: URL(fileURLWithPath: path))
            #expect(file.contains(contents))
            try? fm.removeItem(atPath: path)
        }
    }
    
    @Test func extractsLogsExtractsLogsFromTestAppXCResultToOutputpath() async throws {
        let outputPath = URL.testAssetDir().appending(path: "test")
        try XCResultExtractorReal.extractLogs(xcResultPath: URL.testAsset(path: "TestApp.xcresult").path(),
                                              outputPath: outputPath.path())
        let fm = FileManager.default
        // Check tmp directory not present
        #expect(!fm.fileExists(atPath: outputPath.appending(path: "tmp",
                                                            directoryHint: .isDirectory).path()))
        // Check expected files present (and delete them)
        let expectedFiles = [
            (outputPath.appending(path: "graph.txt",
                                  directoryHint: .notDirectory).path(),
             "StandardOutputAndStandardError"),
            (outputPath.appending(path: "TestAppUITests.txt",
                                  directoryHint: .notDirectory).path(),
             "TestAppUITests-Runner"),
            (outputPath.appending(path: "TestAppUITests-com.chrismash.TestApp.txt",
                                  directoryHint: .notDirectory).path(),
             "App initialised")
        ]
        
        for (path, contents) in expectedFiles {
            #expect(fm.fileExists(atPath: path))
            let file = try String(contentsOf: URL(fileURLWithPath: path))
            #expect(file.contains(contents))
            try? fm.removeItem(atPath: path)
        }
        
        try? fm.removeItem(atPath: outputPath.path())
    }
    
    // TODO: test dir creation throwing error?
    // TODO: test logs?

}
