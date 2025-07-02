//
//  FileDropDelegate.swift
//  XCResultExtractorApp
//
//  Created by Chris Mash on 11/05/2025.
//

import SwiftUI
import UniformTypeIdentifiers

class FileDropDelegate: DropDelegate {
    
    protocol FileReceiver {
        func received(url: URL)
        func received(error: FileError)
    }
    
    enum FileError: Error {
        case noProvider
        case itemLoadFailed(Error)
        case dataNotProvided
        case urlConversionFailed
    }
    
    var fileReceiver: (any FileReceiver)?
    
    func performDrop(info: DropInfo) -> Bool {
        guard let fileReceiver else {
            print("ERROR: no file receiver set")
            return false
        }
        
        let providers = info.itemProviders(for: [.fileURL])
        
        guard let provider = providers.first else {
            fileReceiver.received(error: FileError.noProvider)
            return false
        }
        
        Task {
            do {
                let item = try await provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier)
                guard let data = item as? Data else {
                    print("ERROR: Loaded item was not Data: \(type(of: item))")
                    fileReceiver.received(error: FileError.dataNotProvided)
                    return
                }
                
                guard let url = URL(dataRepresentation: data,
                                    relativeTo: nil,
                                    isAbsolute: true) else {
                    print("ERROR: Failed to convert data to URL: \(data)")
                    fileReceiver.received(error: FileError.urlConversionFailed)
                    return
                }
                
                Task { @MainActor in
                    fileReceiver.received(url: url)
                }
            } catch {
                print("ERROR: Failed to load item: \(error)")
                Task { @MainActor in
                    fileReceiver.received(error: FileError.itemLoadFailed(error))
                }
            }
        }
        
        return true
    }
    
}
