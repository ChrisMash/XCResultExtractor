//
//  XCResultTool.swift
//  XCResultExtractor
//
//  Created by Chris Mash on 28/09/2024.
//

import Foundation

protocol XCResultToolInterface {
    
    func extractGraph(from path: String,
                      outputPath: URL?,
                      shell: ShellInterface,
                      fileHandler: FileHandler) throws -> String
    
    func export(logs: [GraphParser.Log],
                from xcResultPath: String,
                to outputPathBase: String,
                shell: ShellInterface,
                fileHandler: FileHandler) throws
    
}

struct XCResultTool: XCResultToolInterface {
    
    enum ExtractError: Error {
        case xcResultToolError(Error)
        case noOutput
        case errorOutput(String)
    }
    
    func extractGraph(from path: String,
                      outputPath: URL? = nil,
                      shell: ShellInterface,
                      fileHandler: FileHandler) throws -> String {
        let graph: String
        do {
            graph = try shell.execute("xcrun xcresulttool graph --path \(path)/ --legacy")
        } catch {
            throw ExtractError.xcResultToolError(error)
        }
        
        guard !graph.isEmpty else {
            throw ExtractError.noOutput
        }
        
        // Example failure: "Error: File or directory doesn\'t exist at path: ../TestApp.xcresult/.\nUsage: xcresulttool <subcommand>\n  See \'xcresulttool --help\' for more information.\n"
        guard !graph.starts(with: "Error:") else {
            throw ExtractError.errorOutput(graph)
        }
        
        if let outputPath {
            print("Writing graph to \(outputPath.path())")
            do {
                try fileHandler.write(string: graph,
                                      to: outputPath,
                                      atomically: true,
                                      encoding: .utf8)
            } catch {
                print("Error writing graph: \(error)")
            }
        }
        
        return graph
    }
    
    // Note: failures to export are only logged, no errors thrown
    func export(logs: [GraphParser.Log],
                from xcResultPath: String,
                to outputPathBase: String,
                shell: ShellInterface,
                fileHandler: FileHandler) throws {
        let targetOutputPath = URL(fileURLWithPath: outputPathBase)
        let tmpOutputPath = targetOutputPath.appending(path: "tmp",
                                                       directoryHint: .isDirectory)
        try fileHandler.createDirectory(atPath: tmpOutputPath.path(),
                                        withIntermediateDirectories: true,
                                        attributes: nil)
        
        for log in logs {
            let outputPath = tmpOutputPath
                .appending(component: "\(log.name).txt")
                .path(percentEncoded: true)
            let cmdOutput: String
            do {
                cmdOutput = try shell.execute("xcrun xcresulttool export --type file --path \(xcResultPath)/ --output-path \(outputPath) --id \(log.id) --legacy")
            } catch {
                print("Error exporting log: \(error)")
                continue
            }
            
            if !cmdOutput.starts(with: "Exported file with id ") {
                print("Error exporting \(outputPath):\n \(cmdOutput)")
                continue
            } else {
                print("Exported \(outputPath)")
            }
        }
        
        do {
            try fileHandler.moveItems(from: tmpOutputPath,
                                      to: targetOutputPath)
        } catch {
            print("Error moving items from tmp folder \(tmpOutputPath) to \(targetOutputPath): \(error)")
        }
        
        do {
            try fileHandler.removeItem(at: tmpOutputPath)
        } catch {
            print("Error removing tmp folder \(tmpOutputPath): \(error)")
        }
    }
    
}
