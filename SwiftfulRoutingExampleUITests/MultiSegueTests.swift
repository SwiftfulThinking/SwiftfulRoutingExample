//
//  MultiSegueTests.swift
//  SwiftfulRoutingExampleUITests
//
//  Created by Nick Sarno on 3/5/25.
//

import XCTest

final class MultiSegueTests: XCTestCase {

    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = true
        app.launchArguments = ["UI_TESTING", "MULTISEGUES"]
        app.launch()
    }

    override func tearDownWithError() throws {

    }

    // Button identifiers are suffixed with the screen number they render on
    // (ie. "Button_Push3x_0"), so every query resolves to exactly one element
    // regardless of how many screens are stacked.
    private func tapButton(name: String, screen: Int) {
        let button = app.collectionViews.buttons["Button_\(name)_\(screen)"]
        XCTAssertTrue(button.waitForExistence(timeout: 5), "Button_\(name)_\(screen) not found")
        button.tap()
        sleep(1)
    }

    private func assertTitleExists(name: String) {
        let titleElement = app.staticTexts["Title_\(name)"]
        XCTAssertTrue(titleElement.exists)
    }

    private func assertTitleDoesntExist(name: String) {
        let titleElement = app.staticTexts["Title_\(name)"]
        XCTAssertFalse(titleElement.exists)
    }

    private func tapDismiss(count: Int) {
        // Dismiss from the top screen down.
        for screen in (1...count).reversed() {
            tapButton(name: "Dismiss", screen: screen)
        }
    }

    private func testSegues(name: String) {
        tapButton(name: name, screen: 0)
        let count: Int = 3
        assertTitleExists(name: "\(count)")
        tapDismiss(count: count)
        assertTitleExists(name: "0")
        assertTitleDoesntExist(name: "\(count)")
    }

    func test_push3x() throws {
        testSegues(name: "Push3x")
    }

    func test_sheet3x() throws {
        testSegues(name: "Sheet3x")
    }

    func test_full3x() throws {
        testSegues(name: "Full3x")
    }

    func test_pushSheetFull() throws {
        testSegues(name: "PushSheetFull")
    }

    func test_fullSheetPush() throws {
        testSegues(name: "FullSheetPush")
    }

}
