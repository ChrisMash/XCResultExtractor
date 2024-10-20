//
//  XCResultTool.swift
//  XCResultExtractor
//
//  Created by Chris Mash on 28/09/2024.
//

import Foundation

struct XCResultTool {
    
    enum ExtractError: Error {
        case xcResultToolError(Error)
        case noOutput
        case errorOutput(String)
    }
    
    static func extractGraph(from path: String,
                             outputPath: URL? = nil) throws -> String {
        let graph: String
        do {
            graph = try Shell.execute("xcrun xcresulttool graph --path \(path)/ --legacy")
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
                try graph.write(to: outputPath, atomically: true, encoding: .utf8)
            } catch {
                print("Error writing graph: \(error)")
            }
        }
        
        return graph
    }
    
    // Note: failures to export are only logged, no errors thrown
    static func export(logs: [GraphParser.Log],
                       from xcResultPath: String,
                       to outputPathBase: String) {
        for log in logs {
            let outputPath = URL(fileURLWithPath: outputPathBase)
                .appending(component: "\(log.name).txt")
                .path(percentEncoded: true)
            let cmdOutput: String
            do {
                cmdOutput = try Shell.execute("xcrun xcresulttool export --type file --path \(xcResultPath)/ --output-path \(outputPath) --id \(log.id) --legacy")
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
    }
    
    // MARK: Private
    private init() {}
    
}

extension XCResultTool.ExtractError: Equatable {
    
    static func == (lhs: XCResultTool.ExtractError,
                    rhs: XCResultTool.ExtractError) -> Bool {
        switch (lhs, rhs) {
        case (let .xcResultToolError(lhsError), let .xcResultToolError(rhsError)):
            return false // lhsError == rhsError TODO: might want this
        case (.noOutput, .noOutput):
            return true
        case (let .errorOutput(lhsOutput), let .errorOutput(rhsOutput)):
            return lhsOutput == rhsOutput
        default:
            return false
        }
    }
    
}
