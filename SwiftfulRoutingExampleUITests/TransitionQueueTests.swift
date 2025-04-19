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
    
    private func tapElement(name: String) {
        let buttons = app.collectionViews.buttons.matching(identifier: "Button_\(name)")

        if let button = buttons.allElementsBoundByIndex.last {
            button.tap()
            sleep(1)
        }
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
        tapElement(name: "TransitionQueueAppend")
        assertTitleExists(name: "0")
        assertTitleDoesntExist(name: "100")

        tapElement(name: "TransitionQueueNext")
        assertTitleExists(name: "100")

        tapElement(name: "DismissTransition")
        assertTitleDoesntExist(name: "100")
        assertTitleExists(name: "0")
    }
        
    func test_queue_append_multiple() {
        // Append item then insert, ensuring insert is 1st
        
        tapElement(name: "TransitionQueueAppend3")
        assertTitleExists(name: "0")
        assertTitleDoesntExist(name: "300")
        assertTitleDoesntExist(name: "301")
        assertTitleDoesntExist(name: "302")

        tapElement(name: "TransitionQueueNext")
        assertTitleExists(name: "300")
        
        tapElement(name: "TransitionQueueNext")
        assertTitleExists(name: "301")

        tapElement(name: "TransitionQueueNext")
        assertTitleExists(name: "302")

        // Should not do anything
        tapElement(name: "TransitionQueueNext")
        assertTitleExists(name: "302")

        tapElement(name: "DismissTransition")
        assertTitleExists(name: "301")
        assertTitleDoesntExist(name: "302")
        
        tapElement(name: "DismissTransition")
        assertTitleExists(name: "300")
        assertTitleDoesntExist(name: "301")

        tapElement(name: "DismissTransition")
        assertTitleExists(name: "0")
        assertTitleDoesntExist(name: "300")
    }
    
    func test_queue_remove_one() {
        tapElement(name: "TransitionQueueAppend3")
        assertTitleExists(name: "0")
        assertTitleDoesntExist(name: "300")
        assertTitleDoesntExist(name: "301")
        assertTitleDoesntExist(name: "302")

        tapElement(name: "TransitionQueueRemove1")
        
        tapElement(name: "TransitionQueueNext")
        assertTitleExists(name: "300")

        tapElement(name: "TransitionQueueNext")
        assertTitleDoesntExist(name: "301")
        assertTitleExists(name: "302")

        // Should not do anything
        tapElement(name: "TransitionQueueNext")
        assertTitleExists(name: "302")
    }
    
    func test_queue_remove_multiple() {
        tapElement(name: "TransitionQueueAppend3")
        assertTitleExists(name: "0")
        assertTitleDoesntExist(name: "300")
        assertTitleDoesntExist(name: "301")
        assertTitleDoesntExist(name: "302")

        tapElement(name: "TransitionQueueRemove2")

        tapElement(name: "TransitionQueueNext")
        assertTitleDoesntExist(name: "300")
        assertTitleDoesntExist(name: "301")
        assertTitleExists(name: "302")

        // Should not do anything
        tapElement(name: "TransitionQueueNext")
        assertTitleExists(name: "302")
    }
    
    func test_queue_clear() {
        tapElement(name: "TransitionQueueAppend3")
        assertTitleExists(name: "0")
        assertTitleDoesntExist(name: "300")
        assertTitleDoesntExist(name: "301")
        assertTitleDoesntExist(name: "302")

        tapElement(name: "TransitionQueueClear")

        tapElement(name: "TransitionQueueNext")
        assertTitleDoesntExist(name: "300")
        assertTitleDoesntExist(name: "301")
        assertTitleDoesntExist(name: "302")
        assertTitleExists(name: "0")
    }
}
