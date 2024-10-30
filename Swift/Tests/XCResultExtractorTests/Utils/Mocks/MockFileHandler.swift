//
//  MockFileHandler.swift
//  XCResultExtractor
//
//  Created by Chris Mash on 21/10/2024.
//

import Foundation
import XCResultExtractor

class MockFileHandler: FileHandlerInterface {
    
    var cleanUpPaths: [String] = []
    
    deinit {
        let fm = FileManager.default
        for path in cleanUpPaths {
            do {
                try fm.removeItem(at: URL(fileURLWithPath: path))
            } catch {
                print("Error cleaning up \(path): \(error)")
            }
        }
    }
    
    var createDirErrorOut: Error?
    var createDirPathIn: String?
    var createDirIntermediatesIn: Bool?
    var createDirAttributesIn: [FileAttributeKey:Any]?
    
    func createDirectory(atPath path: String,
                         withIntermediateDirectories: Bool,
                         attributes: [FileAttributeKey:Any]?) throws {
        createDirPathIn = path
        createDirIntermediatesIn = withIntermediateDirectories
        createDirAttributesIn = attributes
        
        if let createDirErrorOut {
            throw createDirErrorOut
        }
        
        // Create the directory too, as otherwise xcresulttool fails to output
        if !FileManager.default.fileExists(atPath: path) {
            try FileManager.default.createDirectory(atPath: path,
                                                    withIntermediateDirectories: withIntermediateDirectories,
                                                    attributes: attributes)
            cleanUpPaths.append(path)
        }
    }
    
    
    var moveItemsErrorOut: Error?
    var moveItemsSourceIn: URL?
    var moveItemsDestinationIn: URL?
    
    func moveItems(from source: URL,
                   to destination: URL) throws {
        moveItemsSourceIn = source
        moveItemsDestinationIn = destination
        
        if let moveItemsErrorOut {
            throw moveItemsErrorOut
        }
    }
    
    
    var removeItemErrorOut: Error?
    var removeItemPathIn: URL?
    
    func removeItem(at path: URL) throws {
        removeItemPathIn = path
        
        if let removeItemErrorOut {
            throw removeItemErrorOut
        }
    }
    
    
    var writeErrorOut: Error?
    var writeStringIn: String?
    var writePathIn: URL?
    var writeAtomicIn: Bool?
    var writeEncodingIn: String.Encoding?
    
    func write(string: String,
               to path: URL,
               atomically: Bool,
               encoding: String.Encoding) throws {
        writeStringIn = string
        writePathIn = path
        writeAtomicIn = atomically
        writeEncodingIn = encoding
        
        if let writeErrorOut {
            throw writeErrorOut
        }
    }
    
}
