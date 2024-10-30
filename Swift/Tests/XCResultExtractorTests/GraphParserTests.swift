//
//  GraphParserTests.swift
//  XCResultExtractor
//
//  Created by Chris Mash on 20/10/2024.
//

import Testing
@testable import XCResultExtractor

struct GraphParserTests {

    @Test func testAppTestGraphParsesCorrectly() async throws {
        let sut = GraphParser()
        let graph = try String(testAssetPath: "TestAppGraph.txt")
        let logs = try sut.parseLogs(from: graph)
        try #require(logs.count == 2)
        #expect(logs[0].id == "0~0Hww-uYOGMF9bqddBMEah58BmmEwS_JfHxfWSLbpZt7Nli62Ewvd63aunSOpYrYCF4K8wADFPPOqQRw5qVRxHA==")
        #expect(logs[0].name == "TestAppUITests-com.chrismash.TestApp")
        #expect(logs[1].id == "0~6dJPkHeM01yyOjOgiC4dj4zI3xiZl6WAczFWYwwFHixOyegvKmX1_esi7JTZF4feg8FqKrjnrRAiny7zvcE3yg==")
        #expect(logs[1].name == "TestAppUITests")
    }
    
    @Test func testAppTestGraphMultiParsesCorrectly() async throws {
        let sut = GraphParser()
        let graph = try String(testAssetPath: "TestAppGraphMulti.txt")
        let logs = try sut.parseLogs(from: graph)
        try #require(logs.count == 4)
        #expect(logs[0].id == "0~dGqldtX5W1SsDrMqCGBhnmBsbGLcYiU3WF47VOK7WCygNTrtNxmVvRwovjOuw9RXVhqxb_AaVzAdW2Qx7SOTBA==")
        #expect(logs[0].name == "TestAppTests")
        #expect(logs[1].id == "0~gutSLF4Lfhs2O8hHzzDL8Abtsp1U_lTA4Ze6dk0Pyd7Zg-T8H8MezNcgXNTn29Q3TrtPxi56v88AE6c99m1b_g==")
        #expect(logs[1].name == "TestAppUITests")
        #expect(logs[2].id == "0~lBI7OpIsVuB_q14inPa6rIIikw7N0aIcybArw3lxroQSOA9mixvvIK58neRpOOyQFk9n9D_8Hl6dAxy9zcjfIQ==")
        #expect(logs[2].name == "TestAppUITests-com.chrismash.TestApp")
        #expect(logs[3].id == "0~91Mrf1KkQtqel8yJHw3lvk21d6RbHc_BQ1HlyS1EWYEjnHmC5e1F7fBV8s2kx4QcsYwNX-wCAVVWAudab2nspw==")
        #expect(logs[3].name == "TestAppUITests-2")
    }
    
    @Test func duplicateLogNamesGraphParsesCorrectly() async throws {
        let sut = GraphParser()
        let graph = try String(testAssetPath: "DuplicateLogNamesGraph.txt")
        let logs = try sut.parseLogs(from: graph)
        try #require(logs.count == 3)
        #expect(logs[0].id == "0~gutSLF4Lfhs2O8hHzzDL8Abtsp1U_lTA4Ze6dk0Pyd7Zg-T8H8MezNcgXNTn29Q3TrtPxi56v88AE6c99m1b_g==")
        #expect(logs[0].name == "TestAppUITests")
        #expect(logs[1].id == "0~lBI7OpIsVuB_q14inPa6rIIikw7N0aIcybArw3lxroQSOA9mixvvIK58neRpOOyQFk9n9D_8Hl6dAxy9zcjfIQ==")
        #expect(logs[1].name == "TestAppUITests-2")
        #expect(logs[2].id == "0~91Mrf1KkQtqel8yJHw3lvk21d6RbHc_BQ1HlyS1EWYEjnHmC5e1F7fBV8s2kx4QcsYwNX-wCAVVWAudab2nspw==")
        #expect(logs[2].name == "TestAppUITests-3")
    }
    
    @Test func graphWithoutStdOutputThrowsError() async throws {
        let sut = GraphParser()
        #expect(throws: GraphParser.ParseError.logFilenameNotFound) {
            try sut.parseLogs(from: "not really a graph")
        }
    }
    
    @Test func graphWithoutTargetLogsThrowsError() async throws {
        let sut = GraphParser()
        #expect(throws: GraphParser.ParseError.noDirectoriesFound) {
            try sut.parseLogs(from: "StandardOutputAndStandardError")
        }
    }

}
