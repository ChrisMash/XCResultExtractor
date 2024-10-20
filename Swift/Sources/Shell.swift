//
//  Shell.swift
//  XCResultExtractor
//
//  Created by Chris Mash on 28/09/2024.
//

import Foundation

struct Shell {
    
    enum ShellError: Error {
        case outputParseFailed
    }
    
    // Based on https://stackoverflow.com/a/50035059/1751266
    @discardableResult
    static func execute(_ command: String) throws -> String {
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", command]
        task.executableURL = URL(fileURLWithPath: "/bin/zsh")
        task.standardInput = nil
        
        try task.run()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let output = String(data: data, encoding: .utf8) else {
            throw ShellError.outputParseFailed
        }
        
        return output
    }
    
    // MARK: Private
    private init() {}
    
}
