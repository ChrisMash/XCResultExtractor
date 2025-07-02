//
//  FileDropDelegate.swift
//  XCResultExtractorApp
//
//  Created by Chris Mash on 11/05/2025.
//

import SwiftUI
import UniformTypeIdentifiers
import XCResultTool

class FileDropDelegate: DropDelegate {
    
    protocol FileReceiver {
        func received(files: [URL])
        func received(error: Error)
    }
    
    enum Error: Swift.Error {
        case noProvider
        case itemLoadFailed(Swift.Error)
        case dataNotProvided
        case urlConversionFailed
        case logExtractionFailed(Swift.Error)
    }
    
    var fileReceiver: (any FileReceiver)?
    
    // TODO: on drop there's a second or so of hang (because the VM state only updates after this bit)
    func performDrop(info: DropInfo) -> Bool {
        Task {
            guard let fileReceiver else {
                print("ERROR: no file receiver set")
                return
            }
            
            let providers = info.itemProviders(for: [.fileURL])
            do {
                guard let provider = providers.first else {
                    fileReceiver.received(error: Error.noProvider)
                    return
                }
                
                let item = try await provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier)
                guard let data = item as? Data else {
                    print("ERROR: Loaded item was not Data: \(type(of: item))")
                    fileReceiver.received(error: Error.dataNotProvided)
                    return
                }
                
                guard let url = URL(dataRepresentation: data,
                                    relativeTo: nil,
                                    isAbsolute: true) else {
                    print("ERROR: Failed to convert data to URL: \(data)")
                    fileReceiver.received(error: Error.urlConversionFailed)
                    return
                }
                
                print("Loading \(url)")
                // TODO: hand off to VM? then could be used more generically
                
                // TODO: ensure it's an xcresult that's been dropped
//                Loading file:///Users/chrismash/Documents/TestApp.xcresult.zip
//                Generating .xcresult graph...
//                ERROR: Failed to extract logs: errorOutput("Error: File or directory doesn\'t exist at path: /Users/chrismashm/Documents/TestApp.xcresult.zip/.\nUsage: xcresulttool <subcommand>\n  See \'xcresulttool --help\' for more information.\n")
//                Log extraction failed: logExtractionFailed(XCResultTool.XCResultTool.GraphExtractError.errorOutput("Error: File or directory doesn\'t exist at path: /Users/chrismash/Documents/TestApp.xcresult.zip/.\nUsage: xcresulttool <subcommand>\n  See \'xcresulttool --help\' for more information.\n"))
                
                let shell = Shell()
                let fileHandler = FileHandler()
                let logger = Logger()
                let extractor = LogExtractor(xcResultTool: XCResultTool(shell: shell,
                                                                        fileHandler: fileHandler,
                                                                        logger: logger),
                                             shell: shell,
                                             graphParser: GraphParser(logger: logger),
                                             fileHandler: fileHandler,
                                             logger: logger)
                let outputPath = URL.temporaryDirectory.appendingPathComponent("export",
                                                                               conformingTo: .fileURL)
                do {
                    try extractor.extractLogs(xcResultPath: url.path(),
                                              outputPath: outputPath.path())
                    // TODO: get the above to return the log paths
                    guard let enumerator = FileManager.default.enumerator(atPath: outputPath.path()) else {
                        print("ERROR: Failed to enumerate directory \(outputPath)")
                        return
                    }
                    
                    var files: [URL] = []
                    enumerator.forEach {
                        guard let filename = $0 as? String else {
                            print("ERROR: unexpected filename type: \($0)")
                            return
                        }
                        
                        if filename != "graph.txt" {
                            files.append(outputPath.appendingPathComponent(filename,
                                                                           conformingTo: .fileURL))
                        }
                    }
                    
                    fileReceiver.received(files: files)
                } catch {
                    print("ERROR: Failed to extract logs: \(error)")
                    fileReceiver.received(error: Error.logExtractionFailed(error))
                    return
                }
            } catch {
                print("ERROR: Failed to load item: \(error)")
                fileReceiver.received(error: Error.itemLoadFailed(error))
            }
        }
        
        return true // TODO: return false if it goes wrong?
    }
    
}
