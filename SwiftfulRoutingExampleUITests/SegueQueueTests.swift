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
        // Insert item then append, ensuring append is 2nd
        tapElement(name: "QueueInsert")
        assertTitleExists(name: "0")
        assertTitleDoesntExist(name: "200")
        
        tapElement(name: "QueueAppend")
        assertTitleExists(name: "0")
        assertTitleDoesntExist(name: "100")

        tapElement(name: "QueueNext")
        assertTitleExists(name: "200")
        
        tapElement(name: "QueueNext")
        assertTitleExists(name: "100")

        tapElement(name: "Dismiss")
        assertTitleExists(name: "200")
        assertTitleDoesntExist(name: "100")
        
        tapElement(name: "Dismiss")
        assertTitleExists(name: "0")
        assertTitleDoesntExist(name: "200")
    }
    
    func test_queue_insert() {
        // Append item then insert, ensuring insert is 1st
        
        tapElement(name: "QueueAppend")
        assertTitleExists(name: "0")
        assertTitleDoesntExist(name: "100")

        tapElement(name: "QueueInsert")
        assertTitleExists(name: "0")
        assertTitleDoesntExist(name: "200")

        tapElement(name: "QueueNext")
        assertTitleExists(name: "200")
        
        tapElement(name: "QueueNext")
        assertTitleExists(name: "100")

        tapElement(name: "Dismiss")
        assertTitleExists(name: "200")
        assertTitleDoesntExist(name: "100")
        
        tapElement(name: "Dismiss")
        assertTitleExists(name: "0")
        assertTitleDoesntExist(name: "200")
    }
    
    func test_queue_append_multiple() {
        // Append item then insert, ensuring insert is 1st
        
        tapElement(name: "QueueAppend3")
        assertTitleExists(name: "0")
        assertTitleDoesntExist(name: "300")
        assertTitleDoesntExist(name: "301")
        assertTitleDoesntExist(name: "302")

        tapElement(name: "QueueNext")
        assertTitleExists(name: "300")
        
        tapElement(name: "QueueNext")
        assertTitleExists(name: "301")

        tapElement(name: "QueueNext")
        assertTitleExists(name: "302")

        // Should not do anything
        tapElement(name: "QueueNext")
        assertTitleExists(name: "302")

        tapElement(name: "Dismiss")
        assertTitleExists(name: "301")
        assertTitleDoesntExist(name: "302")
        
        tapElement(name: "Dismiss")
        assertTitleExists(name: "300")
        assertTitleDoesntExist(name: "301")

        tapElement(name: "Dismiss")
        assertTitleExists(name: "0")
        assertTitleDoesntExist(name: "300")
    }
    
    func test_queue_remove_one() {        
        tapElement(name: "QueueAppend3")
        assertTitleExists(name: "0")
        assertTitleDoesntExist(name: "300")
        assertTitleDoesntExist(name: "301")
        assertTitleDoesntExist(name: "302")

        tapElement(name: "QueueRemove1")
        
        tapElement(name: "QueueNext")
        assertTitleExists(name: "300")

        tapElement(name: "QueueNext")
        assertTitleDoesntExist(name: "301")
        assertTitleExists(name: "302")

        // Should not do anything
        tapElement(name: "QueueNext")
        assertTitleExists(name: "302")
    }
    
    func test_queue_remove_multiple() {
        tapElement(name: "QueueAppend3")
        assertTitleExists(name: "0")
        assertTitleDoesntExist(name: "300")
        assertTitleDoesntExist(name: "301")
        assertTitleDoesntExist(name: "302")

        tapElement(name: "QueueRemove2")

        tapElement(name: "QueueNext")
        assertTitleDoesntExist(name: "300")
        assertTitleDoesntExist(name: "301")
        assertTitleExists(name: "302")

        // Should not do anything
        tapElement(name: "QueueNext")
        assertTitleExists(name: "302")
    }
    
    func test_queue_clear() {
        tapElement(name: "QueueAppend3")
        assertTitleExists(name: "0")
        assertTitleDoesntExist(name: "300")
        assertTitleDoesntExist(name: "301")
        assertTitleDoesntExist(name: "302")

        tapElement(name: "QueueClear")

        tapElement(name: "QueueNext")
        assertTitleDoesntExist(name: "300")
        assertTitleDoesntExist(name: "301")
        assertTitleDoesntExist(name: "302")
        assertTitleExists(name: "0")
    }
}
