//
//  FileHandler.swift
//  XCResultExtractor
//
//  Created by Chris Mash on 20/10/2024.
//

import Foundation

public protocol FileHandler {

    func createDirectory(atPath path: String,
                         withIntermediateDirectories createIntermediates: Bool,
                         attributes: [FileAttributeKey:Any]?) throws
    
    func moveItems(from source: URL,
                   to destination: URL) throws
    
    func removeItem(at path: URL) throws
    
    func write(string: String,
               to path: URL,
               atomically: Bool,
               encoding: String.Encoding) throws
    
}

// TODO: UTs
public struct DefaultFileHandler: FileHandler {
    
    enum FileError: Error {
        case failedToEnumerateDirectory
    }
    
    public func createDirectory(atPath path: String,
                                withIntermediateDirectories createIntermediates: Bool,
                                attributes: [FileAttributeKey:Any]?) throws {
        if !FileManager.default.fileExists(atPath: path) {
            try FileManager.default.createDirectory(atPath: path,
                                                    withIntermediateDirectories: createIntermediates,
                                                    attributes: attributes)
        }
    }
    
    public func moveItems(from source: URL,
                          to destination: URL) throws {
        let fm = FileManager.default
        guard let enumerator = fm.enumerator(at: source, includingPropertiesForKeys: nil) else {
            throw FileError.failedToEnumerateDirectory
        }
        
        for case let fileURL as URL in enumerator {
            try fm.moveItem(at: fileURL,
                            to: destination.appending(component: fileURL.lastPathComponent)) // TODO: just log errors and keep trying?
        }
        
    }
    
    public func removeItem(at path: URL) throws {
        try FileManager.default.removeItem(at: path)
    }
    
    public func write(string: String,
                      to path: URL,
                      atomically: Bool,
                      encoding: String.Encoding) throws {
        try string.write(to: path,
                         atomically: atomically,
                         encoding: encoding)
    }
    
}
