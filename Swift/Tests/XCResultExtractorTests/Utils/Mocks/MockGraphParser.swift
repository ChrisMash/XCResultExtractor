//
//  MockGraphParser.swift
//  XCResultExtractor
//
//  Created by Chris Mash on 30/10/2024.
//

@testable import XCResultExtractor

class MockGraphParser: GraphParserInterface {
    
    var parseLogsOut: [Log]?
    var parseErrorOut: Error?
    var parseGraphIn: String?
    
    func parseLogs(from graph: String) throws -> [Log] {
        parseGraphIn = graph
        
        if let parseErrorOut {
            throw parseErrorOut
        }
        
        return parseLogsOut!
    }
    
}
