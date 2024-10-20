import Foundation
import ArgumentParser

// TODO: usage example says the executable is xc-result-extractor but it's actually XCResultExtractor?
// TODO: add logging options to get more info?
// TODO: tests
// TODO: multi-scheme in test app (could perhaps even use UT and integration tests of the package?)
// TODO: catch all errors and wrap them to know what step failed?

@main
struct XCResultExtractor: ParsableCommand {
    
    @Argument(help: "The .xcresult bundle to parse")
    var xcResultPath: String
    
    @Argument(help: "[Optional] Path to write output to, default to the same directory that contains the .xcresult")
    var outputPath: String?
    
    mutating func run() throws {
        print("Generating .xcresult graph...")
        
        // Determine output path, either passed in or taken from .xcresult path
        var outputPathBase: String
        if let outputPath {
            outputPathBase = outputPath
            // Create the directory if it doesn't exist
            if !FileManager.default.fileExists(atPath: outputPathBase) {
                try FileManager.default.createDirectory(atPath: outputPathBase,
                                                        withIntermediateDirectories: true)
            }
        } else {
            let pathURL = URL(filePath: xcResultPath)
            outputPathBase = pathURL
                .deletingLastPathComponent()
                .path(percentEncoded: true)
        }
        
        let graphOutputPath = URL(filePath: outputPathBase)
            .appending(component: "graph.txt")
        let graph = try XCResultTool.extractGraph(from: xcResultPath,
                                                  outputPath: graphOutputPath)
        
        print("Parsing graph...")
        let logs = try GraphParser.parseLogs(from: graph)
        print("Found \(logs.count) log(s)")
        
        XCResultTool.export(logs: logs,
                            from: xcResultPath,
                            to: outputPathBase)
    }
    
}
