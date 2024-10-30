//
//  GraphParser.swift
//  XCResultExtractor
//
//  Created by Chris Mash on 28/09/2024.
//

import Foundation
import RegexBuilder

struct Log {
    let name: String
    let id: String
}

protocol GraphParserInterface {
    func parseLogs(from graph: String) throws -> [Log]
}

// TODO: Session.log useful? just combination of the two?
struct GraphParser: GraphParserInterface {
    
    enum ParseError: Error {
        case logFilenameNotFound
        case noDirectoriesFound
    }
    
    let logger: LoggerInterface
    
    func parseLogs(from graph: String) throws -> [Log] {
        // Example graph (partial):
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
        
        guard graph.contains(Self.logFilename) else {
            throw ParseError.logFilenameNotFound
        }
        
        let casTreeRanges = graph.ranges(of: "* CASTree (file or dir)")
        guard !casTreeRanges.isEmpty else {
            throw ParseError.noDirectoriesFound
        }
        
        var logs: [Log] = []
        for (idx, range) in casTreeRanges.enumerated() {
            let upperBound = idx < (casTreeRanges.count - 1) ? casTreeRanges[idx+1].lowerBound : graph.index(before: graph.endIndex)
            let casTree = graph[range.lowerBound...upperBound]
            if casTree.contains(Self.logFilename) {
                // TODO: all this code is probably optmisable
                guard let idxRef = casTree.range(of: "Refs: ")?.lowerBound else {
                    logger.log("Error trying to find start of logs, skipping target")
                    continue
                }
                
                // We get the substring from "Refs: " up to the std out filename
                guard let rangeOfLog = casTree.range(of: Self.logFilename) else {
                    logger.log("Error trying to find range of log, skipping target")
                    continue
                }
                guard let idxRefsEnd = casTree.range(of: "* ",
                                                     range: rangeOfLog.lowerBound..<casTree.endIndex)?.lowerBound else {
                    logger.log("Error trying to find end of logs, skipping target")
                    continue
                }
    
                let refs = casTree[idxRef...idxRefsEnd].components(separatedBy: "+").dropFirst()
                for (refIdx, ref) in refs.enumerated() where ref.contains(Self.logFilename) {
                    // We then split on the "*" characters,
                    // which gives us an array of the file IDs we can index into
                    let ids = casTree[idxRef..<casTree.endIndex].components(separatedBy: "*")
                    // We extract the file ID from the correct chunk of the output
                    let fileIDLines = ids[refIdx + 1].components(separatedBy: "\n")
                    guard fileIDLines.count > 1 else {
                        logger.log("Error trying to find log ID line, skipping log")
                        continue
                    }
                    let fileIDLine = fileIDLines[1]
                    guard let prefixRange = fileIDLine.range(of: "Id: ") else {
                        logger.log("Error trying to find log ID, skipping log")
                        continue
                    }
                    
                    let fileID = fileIDLine[prefixRange.upperBound...]
                    
                    // Find the name of the target
                    guard let idxLastSession = casTree.range(of: "+ Session-",
                                                             options: .backwards)?.lowerBound else {
                        logger.log("Error trying to find target name, skipping log")
                        continue
                    }
                    
                    let nameLines = casTree[idxLastSession...idxRefsEnd].components(separatedBy: "\n")
                    
                    guard let nameLine = nameLines.first else {
                        logger.log("Error trying to find target name line, skipping log")
                        continue
                    }
                    
                    var name = cleanName(nameLine)
                    if let bundleID = extractBundleID(idx: refIdx, from: nameLines) {
                        name += "-\(bundleID)"
                    }
                    
                    // De-duplicate names where multiple logs under the same session
                    let numMatchingNames = logs.filter { existingLog in
                        if existingLog.name == name {
                            return true
                        }
                        
                        let regex = Regex {
                            name
                            "-"
                            OneOrMore(.digit)
                        }
    
                        return existingLog.name.firstMatch(of: regex) != nil
                    }.count
                    if numMatchingNames > 0 {
                        name += "-\(numMatchingNames + 1)"
                    }
                    
                    logs.append(Log(name: name,
                                    id: String(fileID)))
                }
            }
        }
        
        return logs
    }
    
    // MARK: Private
    private static let logFilename = "StandardOutputAndStandardError"
    
    private func cleanName(_ name: String) -> String {
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
            logger.log("WARNING: failed to clean \(name)")
            return name.removingInvalidFilePathCharacters
        }
    }
    
    private func extractBundleID(idx: Int, from lines: [String]) -> String? {
        // e.g. + Session-TestAppUITests-2024-04-25_185004-TPZle8.log (plainFile)
        //      + StandardOutputAndStandardError-com.chrismash.TestApp.txt (plainFile)  <----- bundle ID included
        //      + StandardOutputAndStandardError.txt (plainFile)                        <----- bundle ID not included
        guard idx < lines.count else {
            logger.log("WARNING: requested bundle ID from line \(idx) when there are only \(lines.count)")
            return nil
        }
        
        let line = lines[idx]
        let regex = Regex {
            "+ \(Self.logFilename)-"
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
