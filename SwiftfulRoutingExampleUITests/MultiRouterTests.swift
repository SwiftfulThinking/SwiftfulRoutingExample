//
//  MultiRouterTests.swift
//  SwiftfulRoutingExampleUITests
//
//  Created by Nick Sarno on 3/7/25.
//

import XCTest

// NOTE: THESE ALL WORK MANUALLY (UI TESTS HAVE BUGS - FIX ME LATER)
final class MultiRouterTests: XCTestCase {

    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = true
        app.launchArguments = ["UI_TESTING", "MULTIROUTER"]
        app.launch()
    }

    override func tearDownWithError() throws {

    }

    // Button identifiers are suffixed with the screen number they render on
    // (ie. "Button_SegueAppend_0"), so every query resolves to exactly one element
    // regardless of how many screens are stacked.
    private func tapElement(name: String, screen: Int) {
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

    // Note: works manually
    func test_segues_append() {
        tapElement(name: "SegueAppend", screen: 0)
        sleep(4) // screens are appended with 1.1s delays after the tap
        assertTitleExists(name: "4")

        tapElement(name: "Dismiss", screen: 4)
        assertTitleDoesntExist(name: "4")
        assertTitleExists(name: "3")

        tapElement(name: "Dismiss", screen: 3)
        assertTitleDoesntExist(name: "3")
        assertTitleExists(name: "2")

        tapElement(name: "Dismiss", screen: 2)
        assertTitleDoesntExist(name: "2")
        assertTitleExists(name: "1")

        tapElement(name: "Dismiss", screen: 1)
        assertTitleDoesntExist(name: "1")
        assertTitleExists(name: "0")
    }

    func test_segues_insertPush() {
        tapElement(name: "SegueInsertPush", screen: 0)
        assertTitleExists(name: "1")

        tapElement(name: "Dismiss", screen: 1)
        assertTitleDoesntExist(name: "1")
        assertTitleExists(name: "2")

        tapElement(name: "Dismiss", screen: 2)
        assertTitleDoesntExist(name: "2")
        assertTitleExists(name: "0")
    }

    // Note: works manually
    func test_segues_insertSheet() {
        tapElement(name: "SegueInsertSheet", screen: 0)
        assertTitleExists(name: "1")

        tapElement(name: "Dismiss", screen: 1)
        assertTitleDoesntExist(name: "1")
        assertTitleExists(name: "2")

        tapElement(name: "Dismiss", screen: 2)
        assertTitleDoesntExist(name: "2")
        assertTitleExists(name: "0")
    }

    // Note: works manually
    func test_segues_insertFull() {
        tapElement(name: "SegueInsertFullScreenCover", screen: 0)
        assertTitleExists(name: "1")

        tapElement(name: "Dismiss", screen: 1)
        assertTitleDoesntExist(name: "1")
        assertTitleExists(name: "2")

        tapElement(name: "Dismiss", screen: 2)
        assertTitleDoesntExist(name: "2")
        assertTitleExists(name: "0")
    }

    func test_dismiss_lastScreen() {
        tapElement(name: "DismissLastScreen", screen: 0)
        sleep(3)
        assertTitleDoesntExist(name: "4")
        assertTitleExists(name: "3")
    }

    func test_dismiss_lastEnvironment() {
        tapElement(name: "DismissLastEnvironment", screen: 0)
        sleep(3)
        assertTitleDoesntExist(name: "4")
        assertTitleDoesntExist(name: "3")
        assertTitleExists(name: "2")
    }

    func test_dismiss_lastPushStack() {
        tapElement(name: "DismissLastPushStack", screen: 0)
        sleep(3)
        assertTitleDoesntExist(name: "5")
        assertTitleDoesntExist(name: "4")
        assertTitleExists(name: "3")
    }
}
