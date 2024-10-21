import Foundation
import ArgumentParser

// TODO: usage example says the executable is xc-result-extractor but it's actually XCResultExtractor?
// TODO: add logging options to get more info?
// TODO: shell script to test the actual exe (unless xcode gives an alternative)
// TODO: multi-scheme in test app (could perhaps even use UT and integration tests of the package?)
// TODO: catch all errors and wrap them to know what step failed?
// TODO: loads of comments
// TODO: consistent URL/String for paths?

@main
struct XCResultExtractor: ParsableCommand {
    
    @Argument(help: "The .xcresult bundle to parse")
    var xcResultPath: String
    
    @Argument(help: "[Optional] Path to write output to, default to the same directory that contains the .xcresult")
    var outputPath: String?
    
    mutating func run() throws {
        try XCResultExtractorReal.extractLogs(xcResultPath: xcResultPath,
                                              outputPath: outputPath)
    }
    
}

// TODO: what's this name? Move to its own file too
struct XCResultExtractorReal {
    
    static func extractLogs(xcResultPath: String,
                            outputPath: String?,
                            xcResultTool: XCResultToolInterface = XCResultTool(),
                            shell: ShellInterface = Shell(),
                            fileHandler: FileHandler = DefaultFileHandler()) throws {
        print("Generating .xcresult graph...")
        
        // Determine output path, either passed in or taken from .xcresult path
        var outputPathBase: String
        if let outputPath {
            outputPathBase = outputPath
            // Create the directory if it doesn't exist
            try fileHandler.createDirectory(atPath: outputPathBase,
                                            withIntermediateDirectories: true,
                                            attributes: nil)
        } else {
            let pathURL = URL(filePath: xcResultPath)
            outputPathBase = pathURL
                .deletingLastPathComponent()
                .path(percentEncoded: true)
        }
        
        // TODO: optional graph output, or just commented out unless debugging?
        let graphOutputPath = URL(filePath: outputPathBase)
            .appending(component: "graph.txt")
        let graph = try xcResultTool.extractGraph(from: xcResultPath,
                                                  outputPath: graphOutputPath,
                                                  shell: shell,
                                                  fileHandler: fileHandler)
        
        print("Parsing graph...")
        let logs = try GraphParser.parseLogs(from: graph)
        print("Found \(logs.count) log(s)")
        
        try xcResultTool.export(logs: logs,
                                from: xcResultPath,
                                to: outputPathBase,
                                shell: shell,
                                fileHandler: fileHandler)
    }
    
}
