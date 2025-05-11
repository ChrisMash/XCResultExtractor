//
//  Logger.swift
//  XCResultExtractor
//
//  Created by Chris Mash on 30/10/2024.
//

public protocol LoggerInterface {
    
    func log(_ message: String)
    
}

public struct Logger: LoggerInterface {
    
    public init() {}
    
    public func log(_ message: String) {
        print(message)
    }
    
}
