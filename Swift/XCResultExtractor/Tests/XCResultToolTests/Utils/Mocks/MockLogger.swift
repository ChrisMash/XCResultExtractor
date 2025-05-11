//
//  MockLogger.swift
//  XCResultExtractor
//
//  Created by Chris Mash on 30/10/2024.
//

@testable import XCResultExtractor

class MockLogger: LoggerInterface {
    
    var messages: [String] = []
    func log(_ message: String) {
        messages.append(message)
    }
    
}
