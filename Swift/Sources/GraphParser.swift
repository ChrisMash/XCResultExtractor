//
//  GraphParser.swift
//  XCResultExtractor
//
//  Created by Chris Mash on 28/09/2024.
//

import Foundation
import RegexBuilder

// TODO: Session.log useful? just combination of the two?
struct GraphParser {
    
    struct Log {
        let name: String
        let id: String
    }
    
    enum ParseError: Error {
        case logFilenameNotFound
        case noTargetsWithLogsFound
    }
    
    static func parseLogs(from graph: String) throws -> [Log] {
        // Example graphOutput:
        //
        //  + simctl_diagnostics (directory)
        //    * CASTree (file or dir)
        //      - Id: 0~25-SBMpEEjRCXcLwupSdWQBlS8RCau8odsmUGfQPktbOq5wKLXaEGP1EhCOVhImnOlbY8e639n9Ps40t-Yq43Q==
        //      - Size: 116
        //      - Refs: 2
        //      + UITests-CC24B8C3-5437-4F76-8EC4-B78B9C24FEDF (directory)
        //      + scheduling.log (plainFile)
        //        * CASTree (file or dir)
        //          - Id: 0~uEROczRoGKiv0pXR2bm7bBTxCk78-CMEoMo4CPimd7uUXqhLzUiYgR07LcP3ADeW2u7co8_XYO1dGW8WNWjEGQ==
        //          - Size: 225
        //          - Refs: 3
        //          + Session-UITests-2024-04-25_095420-64l3KG.log (plainFile)
        //          + StandardOutputAndStandardError-bundleID.txt (plainFile)
        //          + StandardOutputAndStandardError.txt (plainFile)
        //            * raw
        //              - Id: 0~gd6vWsbdASWKEZ-kYenn_Goqw3ch-M1K-o54sORTGy8uWBshemh8BHuIdowxZS4LajYmGC_9Fnt4wNaz0_pLtQ==
        //              - Size: 1591522
        //            * raw
        //              - Id: 0~-bsNCAVy64x2HZHr39QgRonGOGCQxNXYJczwVIR_r41rUSUz5DBiR1Fi5HJT1S6xBY1XSrZnZZamROY8u4NJZg==
        //              - Size: 81203
        //            * raw
        //              - Id: 0~F9oqjEmeWiMP1_l-TGsGm9k4saHmYS1ZazThs1BtxF6X0P26_3wAo5RwrSUgzvsPmIz6S65rvikikGNiKtEKsw==
        //              - Size: 27791
        //        * raw
        //          - Id: 0~ofsFTwYoMfBSsUhsvdnNS-t77QYX84NEiZh3mbROqQBB4-pCRWBxD59FFMdsNQ_ltBCm-PnaZIGD1Rs9PMp6Ig==
        //          - Size: 547
        //    * CASTree (file or dir)
        //      - Id: 0~4VqMqsI5lOfxRppnud6-VDWcNsU8J7VgFCJfW2dXPwOcAkvU-I8Um5yp9n0Zv6nr3VmcxYggaVMDFfR0U_vjKw==
        //      - Size: 2
        
        guard graph.contains(logFilename) else {
            throw ParseError.logFilenameNotFound
        }
        
        // TODO: this gets extra "Refs: " prior to the one we want, which isn't ideal
        // maybe a tokenisation or parsing line by line would be better than a regex?
        let regex = Regex {
            "Refs: "
            ZeroOrMore(.reluctant) {
                /./
            }
            logFilename
            Capture {
                ZeroOrMore(.reluctant) {
                    /./
                }
            }
            "* CASTree"
        }.dotMatchesNewlines()
        let matches = graph.matches(of: regex)
        
        guard !matches.isEmpty else {
            throw ParseError.noTargetsWithLogsFound
        }
        
        print("Found \(matches.count) target(s) with logs")
        
        var logs: [Log] = []
        for match in matches {
            let outputOfInterest = match.0
            // The regex matches from the first "Refs: " (not good enough at regex to avoid that),
            // so we find the last one and know that's the start of the detail we're interested in
            // TODO: updating outputOfInterest to be everything after this idx would be more performant, as the following checks wouldn't need to scan over the earlier stuff we don't want
            guard let idxLastRef = outputOfInterest.range(of: "Refs: ",
                                                          options: .backwards)?.lowerBound else {
                print("Error trying to find start of logs, skipping target")
                continue
            }
            // We get the substring from "Refs: " up to the std out filename
            let rangeOfLog = outputOfInterest.range(of: logFilename)
            guard let idxRefsEnd = outputOfInterest.range(of: "* ",
                                                          range: rangeOfLog!.lowerBound..<outputOfInterest.endIndex)?.lowerBound else {
                print("Error trying to find end of logs, skipping target")
                continue
            }
            
            let refs = outputOfInterest[idxLastRef...idxRefsEnd].components(separatedBy: "+").dropFirst()
            for (refIdx, ref) in refs.enumerated() where ref.contains(logFilename) {
                // We then split on the "*" characters,
                // which gives us an array of the file IDs we can index into
                let ids = outputOfInterest[idxLastRef..<outputOfInterest.endIndex].components(separatedBy: "*")
                // We extract the file ID from the correct chunk of the output
                let fileIDLines = ids[refIdx + 1].components(separatedBy: "\n")
                guard fileIDLines.count > 1 else {
                    print("Error trying to find log ID line, skipping log")
                    continue
                }
                let fileIDLine = fileIDLines[1]
                guard let prefixRange = fileIDLine.range(of: "Id: ") else {
                    print("Error trying to find log ID, skipping log")
                    continue
                }
                
                let fileID = fileIDLine[prefixRange.upperBound...]
                
                // Find the name of the target
                guard let idxLastSession = outputOfInterest.range(of: "+ Session-",
                                                                  options: .backwards)?.lowerBound else {
                    print("Error trying to find target name, skipping log")
                    continue
                }
                
                let nameLines = outputOfInterest[idxLastSession...idxRefsEnd].components(separatedBy: "\n")
                
                guard let nameLine = nameLines.first else {
                    print("Error trying to find target name line, skipping log")
                    continue
                }
                
                var name = cleanName(nameLine)
                if let bundleID = extractBundleID(idx: refIdx, from: nameLines) {
                    name += "-\(bundleID)"
                }
                
                // De-duplicate names where multiple logs under the same session
                let numMatchingNames = logs.filter { existingName in
                    let regex = Regex {
                        existingName.name
                        "-"
                        OneOrMore(.digit)
                    }
                    
                    return name.firstMatch(of: regex) != nil // TODO: want to test this would work if there were two identical names (though potentially unlikely)
                }.count
                if numMatchingNames > 0 {
                    name += "-\(numMatchingNames + 1)"
                }
                
                logs.append(GraphParser.Log(name: name,
                                          id: String(fileID)))
            }
        }
        
        return logs
    }
    
    // MARK: Private
    private static let logFilename = "StandardOutputAndStandardError"
    
    private init() {}
    
    private static func cleanName(_ name: String) -> String {
        // e.g. + Session-TestAppUITests-2024-04-25_185004-TPZle8.log (plainFile)
        let regex = Regex {
            "+ Session-"
            Capture {
              ZeroOrMore(.reluctant) {
                /./
              }
            }
            "-"
            Repeat(count: 4) {
              One(.digit)
            }
            "-"
        }
        
        if let match = name.firstMatch(of: regex) {
            return String(match.output.1)
        } else {
            print("WARNING: failed to clean \(name)")
            return name.removingInvalidFilePathCharacters
        }
    }
    
    private static func extractBundleID(idx: Int, from lines: [String]) -> String? {
        // e.g. + Session-TestAppUITests-2024-04-25_185004-TPZle8.log (plainFile)
        //      + StandardOutputAndStandardError-com.chrismash.TestApp.txt (plainFile)  <----- bundle ID included
        //      + StandardOutputAndStandardError.txt (plainFile)                        <----- bundle ID not included
        let line = lines[idx] // TODO: safety check
        let regex = Regex {
            "+ \(logFilename)-"
            Capture {
              ZeroOrMore(.reluctant) {
                /./
              }
            }
            ".txt"
        }
        
        guard let match = line.firstMatch(of: regex) else {
            return nil
        }
        
        return String(match.output.1)
    }
    
}

fileprivate extension String {
    
    var removingInvalidFilePathCharacters: String {
        filter {
            for scalar in $0.unicodeScalars {
                if !CharacterSet.alphanumerics.contains(scalar) {
                    return false
                }
            }
            return true
        }
    }
    
}
