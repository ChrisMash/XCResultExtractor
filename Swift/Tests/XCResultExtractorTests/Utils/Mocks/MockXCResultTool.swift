//
//  MockXCResultTool.swift
//  XCResultExtractor
//
//  Created by Chris Mash on 21/10/2024.
//

import Foundation
@testable import XCResultExtractor

class MockXCResultTool: XCResultToolInterface {
    
    var extractGraphOut: String?
    var extractErrorOut: Error?
    var extractPathIn: String?
    var extractOutputPathIn: URL?
    
    func extractGraph(from path: String,
                      outputPath: URL?) throws -> String {
        extractPathIn = path
        extractOutputPathIn = outputPath
        
        if let extractErrorOut {
            throw extractErrorOut
        }
        
        return extractGraphOut!
    }
    
    var exportErrorOut: Error?
    var exportLogsIn: [Log]?
    var exportPathIn: String?
    var exportOutputPathIn: String?
    
    func export(logs: [Log],
                from xcResultPath: String,
                to outputPathBase: String) throws {
        exportLogsIn = logs
        exportPathIn = xcResultPath
        exportOutputPathIn = outputPathBase
        
        if let exportErrorOut {
            throw exportErrorOut
        }
    }
    
}
