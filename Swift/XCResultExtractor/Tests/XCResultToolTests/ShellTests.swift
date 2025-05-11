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
        let sut = Shell()
        let output = try sut.execute("ls")
        #expect(output.contains("XCResultExtractor.swiftmodule"))
    }

}
