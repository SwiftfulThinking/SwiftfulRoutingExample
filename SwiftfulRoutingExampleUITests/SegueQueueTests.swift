//
//  SegueQueueTests.swift
//  SwiftfulRoutingExampleUITests
//
//  Created by Nick Sarno on 3/8/25.
//

import XCTest

final class SegueQueueTests: XCTestCase {

    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = true
        app.launchArguments = ["UI_TESTING", "SEGUEQUEUE"]
        app.launch()
    }

    override func tearDownWithError() throws {

    }

    // Button identifiers are suffixed with the screen number they render on
    // (ie. "Button_QueueNext_0"). Queued screens use their queue numbers
    // (100, 200, 300...) as screen numbers.
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
        // Insert item then append, ensuring append is 2nd
        tapElement(name: "QueueInsert", screen: 0)
        assertTitleExists(name: "0")
        assertTitleDoesntExist(name: "200")

        tapElement(name: "QueueAppend", screen: 0)
        assertTitleExists(name: "0")
        assertTitleDoesntExist(name: "100")

        tapElement(name: "QueueNext", screen: 0)
        assertTitleExists(name: "200")

        tapElement(name: "QueueNext", screen: 200)
        assertTitleExists(name: "100")

        tapElement(name: "Dismiss", screen: 100)
        assertTitleExists(name: "200")
        assertTitleDoesntExist(name: "100")

        tapElement(name: "Dismiss", screen: 200)
        assertTitleExists(name: "0")
        assertTitleDoesntExist(name: "200")
    }

    func test_queue_insert() {
        // Append item then insert, ensuring insert is 1st

        tapElement(name: "QueueAppend", screen: 0)
        assertTitleExists(name: "0")
        assertTitleDoesntExist(name: "100")

        tapElement(name: "QueueInsert", screen: 0)
        assertTitleExists(name: "0")
        assertTitleDoesntExist(name: "200")

        tapElement(name: "QueueNext", screen: 0)
        assertTitleExists(name: "200")

        tapElement(name: "QueueNext", screen: 200)
        assertTitleExists(name: "100")

        tapElement(name: "Dismiss", screen: 100)
        assertTitleExists(name: "200")
        assertTitleDoesntExist(name: "100")

        tapElement(name: "Dismiss", screen: 200)
        assertTitleExists(name: "0")
        assertTitleDoesntExist(name: "200")
    }

    func test_queue_append_multiple() {
        tapElement(name: "QueueAppend3", screen: 0)
        assertTitleExists(name: "0")
        assertTitleDoesntExist(name: "300")
        assertTitleDoesntExist(name: "301")
        assertTitleDoesntExist(name: "302")

        tapElement(name: "QueueNext", screen: 0)
        assertTitleExists(name: "300")

        tapElement(name: "QueueNext", screen: 300)
        assertTitleExists(name: "301")

        tapElement(name: "QueueNext", screen: 301)
        assertTitleExists(name: "302")

        // Should not do anything
        tapElement(name: "QueueNext", screen: 302)
        assertTitleExists(name: "302")

        tapElement(name: "Dismiss", screen: 302)
        assertTitleExists(name: "301")
        assertTitleDoesntExist(name: "302")

        tapElement(name: "Dismiss", screen: 301)
        assertTitleExists(name: "300")
        assertTitleDoesntExist(name: "301")

        tapElement(name: "Dismiss", screen: 300)
        assertTitleExists(name: "0")
        assertTitleDoesntExist(name: "300")
    }

    func test_queue_remove_one() {
        tapElement(name: "QueueAppend3", screen: 0)
        assertTitleExists(name: "0")
        assertTitleDoesntExist(name: "300")
        assertTitleDoesntExist(name: "301")
        assertTitleDoesntExist(name: "302")

        tapElement(name: "QueueRemove1", screen: 0)

        tapElement(name: "QueueNext", screen: 0)
        assertTitleExists(name: "300")

        tapElement(name: "QueueNext", screen: 300)
        assertTitleDoesntExist(name: "301")
        assertTitleExists(name: "302")

        // Should not do anything
        tapElement(name: "QueueNext", screen: 302)
        assertTitleExists(name: "302")
    }

    func test_queue_remove_multiple() {
        tapElement(name: "QueueAppend3", screen: 0)
        assertTitleExists(name: "0")
        assertTitleDoesntExist(name: "300")
        assertTitleDoesntExist(name: "301")
        assertTitleDoesntExist(name: "302")

        tapElement(name: "QueueRemove2", screen: 0)

        tapElement(name: "QueueNext", screen: 0)
        assertTitleDoesntExist(name: "300")
        assertTitleDoesntExist(name: "301")
        assertTitleExists(name: "302")

        // Should not do anything
        tapElement(name: "QueueNext", screen: 302)
        assertTitleExists(name: "302")
    }

    func test_queue_clear() {
        tapElement(name: "QueueAppend3", screen: 0)
        assertTitleExists(name: "0")
        assertTitleDoesntExist(name: "300")
        assertTitleDoesntExist(name: "301")
        assertTitleDoesntExist(name: "302")

        tapElement(name: "QueueClear", screen: 0)

        tapElement(name: "QueueNext", screen: 0)
        assertTitleDoesntExist(name: "300")
        assertTitleDoesntExist(name: "301")
        assertTitleDoesntExist(name: "302")
        assertTitleExists(name: "0")
    }
}
