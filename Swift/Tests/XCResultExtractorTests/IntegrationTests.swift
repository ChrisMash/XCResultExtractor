//
//  IntegrationTests.swift
//  XCResultExtractor
//
//  Created by Chris Mash on 21/10/2024.
//

import Testing
import Foundation
@testable import XCResultExtractor

@Suite(.serialized)
struct IntegrationTests {

    @Test func extractsLogsExtractsLogsFromTestAppMultiXCResult() async throws {
        let sut = makeSUT()
        try sut.extractLogs(xcResultPath: URL.testAsset(path: "TestAppMulti.xcresult").path(),
                            outputPath: nil)
        // Check tmp directory not present
        let testAssetsDir = URL.testAssetDir()
        let tmpPath = testAssetsDir.appending(path: "tmp",
                                              directoryHint: .isDirectory).path()
        #expect(!FileManager.default.fileExists(atPath: tmpPath))
        // Check expected files present (and delete them)
        try expectFiles([
            // Graph
            ("graph.txt", "StandardOutputAndStandardError"),
            // UI test logs?
            ("TestAppUITests.txt", "*** If you believe this error represents a bug"),
            // UI test logs
            ("TestAppUITests-2.txt", "TestAppUITests-Runner"),
            // Test app logs (from UI tests)
            ("TestAppUITests-com.chrismash.TestApp.txt", "App initialised"),
            // UT logs
            ("TestAppTests.txt", "App initialised")
        ],
                        in: testAssetsDir,
                        others: testAssets)
    }
    
    @Test func extractsLogsExtractsLogsFromTestAppXCResult() async throws {
        let sut = makeSUT()
        try sut.extractLogs(xcResultPath: URL.testAsset(path: "TestApp.xcresult").path(),
                            outputPath: nil)
        // Check tmp directory not present
        let testAssetsDir = URL.testAssetDir()
        let tmpPath = testAssetsDir.appending(path: "tmp",
                                              directoryHint: .isDirectory).path()
        #expect(!FileManager.default.fileExists(atPath: tmpPath))
        // Check expected files present (and delete them)
        try expectFiles([
            // Graph
            ("graph.txt", "StandardOutputAndStandardError"),
            // UI test logs
            ("TestAppUITests.txt", "TestAppUITests-Runner"),
            // Test app logs (from UI tests)
            ("TestAppUITests-com.chrismash.TestApp.txt", "App initialised")
        ],
                        in: testAssetsDir,
                        others: testAssets)
    }
    
    @Test func extractsLogsExtractsLogsFromTestAppXCResultToOutputpath() async throws {
        let sut = makeSUT()
        let outputPath = URL.testAssetDir().appending(path: "test")
        try sut.extractLogs(xcResultPath: URL.testAsset(path: "TestApp.xcresult").path(),
                            outputPath: outputPath.path())
        // Check tmp directory not present
        let fm = FileManager.default
        let tmpPath = outputPath.appending(path: "tmp",
                                           directoryHint: .isDirectory).path()
        #expect(!fm.fileExists(atPath: tmpPath))
        
        // Check expected files present (and delete them)
        try expectFiles([
            ("graph.txt", "StandardOutputAndStandardError"),
            ("TestAppUITests.txt", "TestAppUITests-Runner"),
            ("TestAppUITests-com.chrismash.TestApp.txt", "App initialised")
        ],
                        in: outputPath)
        
        // Remove the output path
        try? fm.removeItem(atPath: outputPath.path())
    }
    
    // MARK: Private
    private func makeSUT() -> LogExtractor {
        let logger = Logger()
        let shell = Shell()
        let fileHandler = FileHandler()
        return LogExtractor(xcResultTool: XCResultTool(shell: shell,
                                                       fileHandler: fileHandler,
                                                       logger: logger),
                            shell: shell,
                            graphParser: GraphParser(logger: logger),
                            fileHandler: fileHandler,
                            logger: logger)
    }
    
    /// Checks the expected files exist with the expected content in the specified directory, deleting them afterwards.
    /// Takes an array of other filenames expected in the directory to check the expected total count. These files won't be deleted.
    private func expectFiles(_ expectedFiles: [(String, String)],
                             in dir: URL,
                             others otherFiles: [String] = [],
                             sourceLocation: SourceLocation = #_sourceLocation) throws {
        let fm = FileManager.default
        var files = try fm.contentsOfDirectory(at: dir,
                                               includingPropertiesForKeys: nil)
        #expect(files.count == expectedFiles.count + otherFiles.count, sourceLocation: sourceLocation)
        for (filename, contents) in expectedFiles {
            let path = dir.appending(path: filename,
                                     directoryHint: .notDirectory)
            #expect(files.contains { $0 == path },
                    sourceLocation: sourceLocation)
            let file = try String(contentsOf: path)
            #expect(file.contains(contents),
                    sourceLocation: sourceLocation)
            let deletingTestAsset = testAssets.contains(where: {
                path.lastPathComponent == $0
            })
            guard !deletingTestAsset else {
                #expect(Bool(false), "Trying to delete a test asset",
                        sourceLocation: sourceLocation)
                return
            }
            try? fm.removeItem(atPath: path.path())
            
            guard let idx = files.firstIndex(of: path) else {
                #expect(Bool(false), "")
                continue
            }
            files.remove(at: idx)
        }
        
        #expect(otherFiles.containsSameElements(as: files.map { $0.lastPathComponent }),
                sourceLocation: sourceLocation)
    }
    
}

extension Array where Element: Comparable {
    
    func containsSameElements(as other: [Element]) -> Bool {
        count == other.count
        && sorted() == other.sorted()
    }
    
}
