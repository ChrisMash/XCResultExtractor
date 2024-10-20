//
//  ShellTests.swift
//  XCResultExtractor
//
//  Created by Chris Mash on 20/10/2024.
//

import Testing
@testable import XCResultExtractor

struct ShellTests {

    @Test func executeLSReturnsExpectedOutput() async throws {
        let output = try Shell.execute("ls")
        print(output)
        #expect(output.contains("XCResultExtractor.swiftmodule"))
    }

}