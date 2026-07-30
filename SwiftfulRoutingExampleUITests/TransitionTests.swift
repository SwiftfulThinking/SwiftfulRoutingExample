//
//  TransitionTests.swift
//  SwiftfulRoutingExampleUITests
//
//  Created by Nick Sarno on 3/31/25.
//
import XCTest

final class TransitionTests: XCTestCase {

    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = true
        app.launchArguments = ["UI_TESTING", "TRANSITIONS"]
        app.launch()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // Button identifiers are suffixed with the screen number they render on
    // (ie. "Button_TransitionTrailing_0"), so every query resolves to exactly one
    // element even when transition screens keep the previous screen rendered.
    private func tapElement(name: String, screen: Int) {
        let button = app.collectionViews.buttons["Button_\(name)_\(screen)"]

        // List rows below the fold are lazy and do not exist in the accessibility
        // tree until scrolled near-visible. Swipe up to reveal them if needed.
        var attempts = 0
        while !(button.exists && button.isHittable) && attempts < 4 {
            app.swipeUp()
            attempts += 1
        }

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

    func test_showTransition() {
        tapElement(name: "TransitionTrailing", screen: 0)
        assertTitleExists(name: "1")
    }

    func test_showTransitions() {
        tapElement(name: "2Transitions", screen: 0)
        assertTitleExists(name: "701")
        tapElement(name: "DismissTransition", screen: 701)
        assertTitleExists(name: "700")
    }

    func test_dismissTransition() {
        tapElement(name: "TransitionTrailing", screen: 0)
        assertTitleExists(name: "1")

        tapElement(name: "DismissTransition", screen: 1)
        assertTitleDoesntExist(name: "1")
    }

    func test_dismissTransition_id() {
        tapElement(name: "TransitionTrailing", screen: 0)
        assertTitleExists(name: "1")

        tapElement(name: "DismissTransitionId1", screen: 1)
        assertTitleDoesntExist(name: "1")
    }

    func test_dismissModal_count() {
        tapElement(name: "TransitionTrailing", screen: 0)
        assertTitleExists(name: "1")

        tapElement(name: "TransitionTrailing", screen: 1)
        assertTitleExists(name: "2")

        tapElement(name: "TransitionTrailing", screen: 2)
        assertTitleExists(name: "3")

        tapElement(name: "Dismiss2Transitions", screen: 3)
        assertTitleDoesntExist(name: "3")
        assertTitleDoesntExist(name: "2")
        assertTitleExists(name: "1")
    }

    func test_dismissModal_upToId() {
        tapElement(name: "TransitionTrailing", screen: 0)
        assertTitleExists(name: "1")

        tapElement(name: "TransitionTrailing", screen: 1)
        assertTitleExists(name: "2")

        tapElement(name: "TransitionTrailing", screen: 2)
        assertTitleExists(name: "3")

        tapElement(name: "DismissupToTransition1", screen: 3)
        assertTitleDoesntExist(name: "3")
        assertTitleDoesntExist(name: "2")
        assertTitleExists(name: "1")
    }

    func test_dismissModal_all() {
        tapElement(name: "TransitionTrailing", screen: 0)
        assertTitleExists(name: "1")

        tapElement(name: "TransitionTrailing", screen: 1)
        assertTitleExists(name: "2")

        tapElement(name: "TransitionTrailing", screen: 2)
        assertTitleExists(name: "3")

        tapElement(name: "DismissAllTransitions", screen: 3)
        assertTitleDoesntExist(name: "3")
        assertTitleDoesntExist(name: "2")
        assertTitleDoesntExist(name: "1")
        assertTitleExists(name: "0")
    }

}
