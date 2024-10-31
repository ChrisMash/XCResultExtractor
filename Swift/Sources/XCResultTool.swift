//
//  XCResultTool.swift
//  XCResultExtractor
//
//  Created by Chris Mash on 28/09/2024.
//

import Foundation

protocol XCResultToolInterface {
    
    func extractGraph(from path: String,
                      outputPath: URL?) throws -> String
    
    func export(logs: [Log],
                from xcResultPath: String,
                to outputPathBase: String) throws
    
}

struct XCResultTool: XCResultToolInterface {
    
    let shell: ShellInterface
    let fileHandler: FileHandlerInterface
    let logger: LoggerInterface
    
    enum GraphExtractError: Error {
        case xcResultToolError(Error)
        case noOutput
        case errorOutput(String)
    }

    func extractGraph(from path: String,
                      outputPath: URL? = nil) throws -> String {
        let graph: String
        do {
            graph = try shell.execute("xcrun xcresulttool graph --path \(path)/ --legacy")
        } catch {
            throw GraphExtractError.xcResultToolError(error)
        }
        
        guard !graph.isEmpty else {
            throw GraphExtractError.noOutput
        }
        
        // Example failure: "Error: File or directory doesn\'t exist at path: ../TestApp.xcresult/.\nUsage: xcresulttool <subcommand>\n  See \'xcresulttool --help\' for more information.\n"
        guard !graph.starts(with: "Error:") else {
            throw GraphExtractError.errorOutput(graph)
        }
        
        if let outputPath {
            let fileOutputPath = outputPath.appending(path: "graph.txt",
                                                      directoryHint: .notDirectory)
            logger.log("Writing graph to \(fileOutputPath.path())")
            do {
                try fileHandler.write(string: graph,
                                      to: fileOutputPath,
                                      atomically: true,
                                      encoding: .utf8)
            } catch {
                logger.log("Error writing graph: \(error)")
            }
        }
        
        return graph
    }
    
    enum LogExportError: Error {
        case noLogsProvided
        case createOutputDirectoryFailed(Error)
    }
    
    // Note: failures to export are only logged, no errors thrown
    func export(logs: [Log],
                from xcResultPath: String,
                to outputPathBase: String) throws {
        guard !logs.isEmpty else {
            throw LogExportError.noLogsProvided
        }
        
        let targetOutputPath = URL(fileURLWithPath: outputPathBase)
        let tmpOutputPath = targetOutputPath.appending(path: "tmp",
                                                       directoryHint: .isDirectory)
        do {
            try fileHandler.createDirectory(atPath: tmpOutputPath.path(),
                                            withIntermediateDirectories: true,
                                            attributes: nil)
        } catch {
            throw LogExportError.createOutputDirectoryFailed(error)
        }
        
        // TODO: all these catches only logging is... fine?
        for log in logs {
            let outputPath = tmpOutputPath
                .appending(component: "\(log.name).txt")
                .path(percentEncoded: true)
            let cmdOutput: String
            do {
                cmdOutput = try shell.execute("xcrun xcresulttool export --type file --path \(xcResultPath)/ --output-path \(outputPath) --id \(log.id) --legacy")
            } catch {
                logger.log("Error exporting log: \(error)")
                continue
            }
            
            if !cmdOutput.starts(with: "Exported file with id ") {
                logger.log("Error exporting \(outputPath):\n \(cmdOutput)")
                continue
            } else {
                logger.log("Exported \(outputPath)")
            }
        }
        
        do {
            try fileHandler.moveItems(from: tmpOutputPath,
                                      to: targetOutputPath)
        } catch {
            logger.log("Error moving items from tmp folder \(tmpOutputPath) to \(targetOutputPath): \(error)")
        }
        
        do {
            try fileHandler.removeItem(at: tmpOutputPath)
        } catch {
            logger.log("Error removing tmp folder \(tmpOutputPath): \(error)")
        }
    }
    
}
