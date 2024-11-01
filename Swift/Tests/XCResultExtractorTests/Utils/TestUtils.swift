//
//  TestUtils.swift
//  XCResultExtractor
//
//  Created by Chris Mash on 30/10/2024.
//

import Testing

struct TestError: Error {}

func expectThrows(_ closure: () throws -> Any,
                  error errorMatcher: (Error) throws -> Void,
                  sourceLocation: SourceLocation = #_sourceLocation) throws {
//        #expect(throws: .someError(TestError())) {
//            try sut.extractGraph(from: "some path",
//                                 shell: mockShell,
//                                 fileHandler: MockFileHandler())
//        }
    
    // Above doesn't match properly, so doing it this way!
    do {
        let _ = try closure()
        #expect(Bool(false),
                "Expected error to be thrown, but wasn't",
                sourceLocation: sourceLocation)
    } catch {
        try errorMatcher(error)
    }
}

let testAssets = [
    "DuplicateLogNamesGraph.txt",
    "TestApp.xcresult",
    "TestAppGraph.txt",
    "TestAppGraphMulti.txt",
    "TestAppMulti.xcresult",
    ".DS_Store"
]
