//
//  MockShell.swift
//  XCResultExtractor
//
//  Created by Chris Mash on 21/10/2024.
//

@testable import XCResultExtractor

class MockShell: ShellInterface {
    
    var executeOutput: String?
    var executeErrorOut: Error?
    var executeCommandIn: String?
    
    func execute(_ command: String) throws -> String {
        executeCommandIn = command
        
        if let executeErrorOut {
            throw executeErrorOut
        }
        
        return executeOutput!
    }
    
}
