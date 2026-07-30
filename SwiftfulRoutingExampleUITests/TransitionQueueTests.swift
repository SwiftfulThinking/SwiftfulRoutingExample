//
//  TransitionQueueTests.swift
//  SwiftfulRoutingExampleUITests
//
//  Created by Nick Sarno on 3/31/25.
//
import XCTest

final class TransitionQueueTests: XCTestCase {

    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = true
        app.launchArguments = ["UI_TESTING", "TRANSITIONQUEUE"]
        app.launch()
    }

    override func tearDownWithError() throws {

    }

    // Button identifiers are suffixed with the screen number they render on
    // (ie. "Button_TransitionQueueNext_0"). Queued transitions use their queue
    // numbers (100, 300...) as screen numbers.
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

    func test_queue_append() {
        tapElement(name: "TransitionQueueAppend", screen: 0)
        assertTitleExists(name: "0")
        assertTitleDoesntExist(name: "100")

        tapElement(name: "TransitionQueueNext", screen: 0)
        assertTitleExists(name: "100")

        tapElement(name: "DismissTransition", screen: 100)
        assertTitleDoesntExist(name: "100")
        assertTitleExists(name: "0")
    }

    func test_queue_append_multiple() {
        tapElement(name: "TransitionQueueAppend3", screen: 0)
        assertTitleExists(name: "0")
        assertTitleDoesntExist(name: "300")
        assertTitleDoesntExist(name: "301")
        assertTitleDoesntExist(name: "302")

        tapElement(name: "TransitionQueueNext", screen: 0)
        assertTitleExists(name: "300")

        tapElement(name: "TransitionQueueNext", screen: 300)
        assertTitleExists(name: "301")

        tapElement(name: "TransitionQueueNext", screen: 301)
        assertTitleExists(name: "302")

        // Should not do anything
        tapElement(name: "TransitionQueueNext", screen: 302)
        assertTitleExists(name: "302")

        tapElement(name: "DismissTransition", screen: 302)
        assertTitleExists(name: "301")
        assertTitleDoesntExist(name: "302")

        tapElement(name: "DismissTransition", screen: 301)
        assertTitleExists(name: "300")
        assertTitleDoesntExist(name: "301")

        tapElement(name: "DismissTransition", screen: 300)
        assertTitleExists(name: "0")
        assertTitleDoesntExist(name: "300")
    }

    func test_queue_remove_one() {
        tapElement(name: "TransitionQueueAppend3", screen: 0)
        assertTitleExists(name: "0")
        assertTitleDoesntExist(name: "300")
        assertTitleDoesntExist(name: "301")
        assertTitleDoesntExist(name: "302")

        tapElement(name: "TransitionQueueRemove1", screen: 0)

        tapElement(name: "TransitionQueueNext", screen: 0)
        assertTitleExists(name: "300")

        tapElement(name: "TransitionQueueNext", screen: 300)
        assertTitleDoesntExist(name: "301")
        assertTitleExists(name: "302")

        // Should not do anything
        tapElement(name: "TransitionQueueNext", screen: 302)
        assertTitleExists(name: "302")
    }

    func test_queue_remove_multiple() {
        tapElement(name: "TransitionQueueAppend3", screen: 0)
        assertTitleExists(name: "0")
        assertTitleDoesntExist(name: "300")
        assertTitleDoesntExist(name: "301")
        assertTitleDoesntExist(name: "302")

        tapElement(name: "TransitionQueueRemove2", screen: 0)

        tapElement(name: "TransitionQueueNext", screen: 0)
        assertTitleDoesntExist(name: "300")
        assertTitleDoesntExist(name: "301")
        assertTitleExists(name: "302")

        // Should not do anything
        tapElement(name: "TransitionQueueNext", screen: 302)
        assertTitleExists(name: "302")
    }

    func test_queue_clear() {
        tapElement(name: "TransitionQueueAppend3", screen: 0)
        assertTitleExists(name: "0")
        assertTitleDoesntExist(name: "300")
        assertTitleDoesntExist(name: "301")
        assertTitleDoesntExist(name: "302")

        tapElement(name: "TransitionQueueClear", screen: 0)

        tapElement(name: "TransitionQueueNext", screen: 0)
        assertTitleDoesntExist(name: "300")
        assertTitleDoesntExist(name: "301")
        assertTitleDoesntExist(name: "302")
        assertTitleExists(name: "0")
    }
}
