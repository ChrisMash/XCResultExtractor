//
//  LogExtractor.swift
//  XCResultExtractor
//
//  Created by Chris Mash on 26/10/2024.
//

import Foundation

struct LogExtractor {
    
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
