//
//  LogExtractor.swift
//  XCResultExtractor
//
//  Created by Chris Mash on 26/10/2024.
//

import Foundation

public enum LogExtractError: Error {
    case createOutputDirectoryFailed(Error)
}

struct LogExtractor {
    
    static func extractLogs(xcResultPath: String,
                            outputPath: String?,
                            xcResultTool: XCResultToolInterface = XCResultTool(),
                            shell: ShellInterface = Shell(),
                            graphParser: GraphParserProtocol = GraphParser(),
                            fileHandler: FileHandler = DefaultFileHandler()) throws {
        print("Generating .xcresult graph...")
        
        // Determine output path, either passed in or taken from .xcresult path
        var outputPathBase: String
        if let outputPath {
            outputPathBase = outputPath
            // Create the directory if it doesn't exist
            do {
                try fileHandler.createDirectory(atPath: outputPathBase,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
            } catch {
                throw LogExtractError.createOutputDirectoryFailed(error)
            }
        } else {
            let pathURL = URL(filePath: xcResultPath)
            outputPathBase = pathURL
                .deletingLastPathComponent()
                .path(percentEncoded: true)
        }
        
        // TODO: optional graph output, or just commented out unless debugging?
        let graph = try xcResultTool.extractGraph(from: xcResultPath,
                                                  outputPath: URL(filePath: outputPathBase),
                                                  shell: shell,
                                                  fileHandler: fileHandler)
        
        print("Parsing graph...")
        let logs = try graphParser.parseLogs(from: graph)
        print("Found \(logs.count) log(s)")
        
        try xcResultTool.export(logs: logs,
                                from: xcResultPath,
                                to: outputPathBase,
                                shell: shell,
                                fileHandler: fileHandler)
    }
    
}
