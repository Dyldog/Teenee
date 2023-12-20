//
//  TeeUITests.swift
//  TeeUITests
//
//  Created by Dylan Elliott on 26/11/2023.
//

import XCTest

final class TeeUITests: XCTestCase {

    private var app: XCUIApplication!
    
    override func setUp() {
        app = XCUIApplication()
        app.launchArguments = ["TESTMODE"]
        setupSnapshot(app)
        app.launch()
    }

    func testScreenshots() throws {
        snapshot("Home")
    }
}
