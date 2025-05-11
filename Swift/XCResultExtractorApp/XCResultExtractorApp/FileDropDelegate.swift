//
//  FileDropDelegate.swift
//  XCResultExtractorApp
//
//  Created by Chris Mash on 11/05/2025.
//

import SwiftUI
import UniformTypeIdentifiers

class FileDropDelegate: DropDelegate {
    
    func performDrop(info: DropInfo) -> Bool {
        Task {
            let providers = info.itemProviders(for: [.fileURL])
            do {
                let item = try await providers.first!.loadItem(forTypeIdentifier: UTType.fileURL.identifier)
                guard let data = item as? Data else {
                    print("ERROR: Loaded item was not Data: \(type(of: item))")
                    return
                }
                guard let url = URL(dataRepresentation: data,
                                    relativeTo: nil,
                                    isAbsolute: true) else {
                    print("ERROR: Failed to convert data to URL: \(data)")
                    return
                }
                print("Loading \(url)")
                // TODO: hand off to VM
                
            } catch {
                print("ERROR: Failed to load item: \(error)")
            }
        }
        return true // TODO: return false if it goes wrong?
    }
    
}
