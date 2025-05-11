//
//  LogExtractor.swift
//  XCResultExtractor
//
//  Created by Chris Mash on 26/10/2024.
//

import Foundation

public struct LogExtractor {
    
    public enum ExtractError: Error {
        case createOutputDirectoryFailed(Error)
    }
    
    private let xcResultTool: XCResultToolInterface
    private let shell: ShellInterface
    private let graphParser: GraphParserInterface
    private let fileHandler: FileHandlerInterface
    private let logger: LoggerInterface
    
    public init(xcResultTool: any XCResultToolInterface,
                shell: any ShellInterface,
                graphParser: any GraphParserInterface,
                fileHandler: any FileHandlerInterface,
                logger: any LoggerInterface) {
        self.xcResultTool = xcResultTool
        self.shell = shell
        self.graphParser = graphParser
        self.fileHandler = fileHandler
        self.logger = logger
    }
    
    public func extractLogs(xcResultPath: String,
                     outputPath: String?) throws {
        logger.log("Generating .xcresult graph...")
        
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
                throw ExtractError.createOutputDirectoryFailed(error)
            }
        } else {
            let pathURL = URL(filePath: xcResultPath)
            outputPathBase = pathURL
                .deletingLastPathComponent()
                .path(percentEncoded: true)
        }
        
        // TODO: optional graph output, or just commented out unless debugging?
        let graph = try xcResultTool.extractGraph(from: xcResultPath,
                                                  outputPath: URL(filePath: outputPathBase))
        
        logger.log("Parsing graph...")
        let logs = try graphParser.parseLogs(from: graph)
        logger.log("Found \(logs.count) log(s)")
        
        try xcResultTool.export(logs: logs,
                                from: xcResultPath,
                                to: outputPathBase)
    }
    
}
