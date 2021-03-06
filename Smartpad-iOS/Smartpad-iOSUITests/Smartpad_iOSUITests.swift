//
//  Smartpad_iOSUITests.swift
//  Smartpad-iOSUITests
//
//  Created by Alireza Azimi on 2022-03-08.
//

import XCTest

class Smartpad_iOSUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        app = XCUIApplication()
        app.launchArguments.append("--uitesting")
    }

    func testUINavigation() throws {
        app.launch()
        if (app.isDisplayingSetup) {
            app.textFields.element.tap()
            app.textFields.element.typeText("ui test ios\n")
        }
        XCTAssertTrue(app.isDisplayingMain)
        app.buttons["pairButton"].tap()
        app.buttons["settingsButton"].tap()
        app.buttons["settingsButton"].tap()
        app.buttons["backButton"].tap()
    }
}

extension XCUIApplication {
    var isDisplayingSetup: Bool {
        return otherElements["setupView"].exists
    }
    
    var isDisplayingMain: Bool {
        return otherElements["mainView"].exists
    }
}
