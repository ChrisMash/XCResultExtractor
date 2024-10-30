//
//  Logger.swift
//  XCResultExtractor
//
//  Created by Chris Mash on 30/10/2024.
//

protocol LoggerInterface {
    
    func log(_ message: String)
    
}

struct Logger: LoggerInterface {
    
    func log(_ message: String) {
        print(message)
    }
    
}
