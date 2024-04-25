//
//  TestAppUITests.swift
//  TestAppUITests
//
//  Created by Chris Mash on 25/04/2024.
//

import XCTest

final class TestAppUITests: XCTestCase {

    func testExample() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["Hello, world!"].waitForExistence(timeout: 5))
    }

}
