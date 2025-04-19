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
    
    // Note: works manually
    func test_segues_append() {
        tapElement(name: "SegueAppend")
        assertTitleExists(name: "4")
        
        tapElement(name: "Dismiss")
        assertTitleDoesntExist(name: "4")
        assertTitleExists(name: "3")
        
        tapElement(name: "Dismiss")
        assertTitleDoesntExist(name: "3")
        assertTitleExists(name: "2")

        tapElement(name: "Dismiss")
        assertTitleDoesntExist(name: "2")
        assertTitleExists(name: "1")

        tapElement(name: "Dismiss")
        assertTitleDoesntExist(name: "1")
        assertTitleExists(name: "0")
    }
    
    func test_segues_insertPush() {
        tapElement(name: "SegueInsertPush")
        assertTitleExists(name: "1")
        
        tapElement(name: "Dismiss")
        assertTitleDoesntExist(name: "1")
        assertTitleExists(name: "2")
        
        tapElement(name: "Dismiss")
        assertTitleDoesntExist(name: "2")
        assertTitleExists(name: "0")
    }
    
    // Note: works manually
    func test_segues_insertSheet() {
        tapElement(name: "SegueInsertSheet")
        assertTitleExists(name: "1")
        
        tapElement(name: "Dismiss")
        assertTitleDoesntExist(name: "1")
        assertTitleExists(name: "2")
        
        tapElement(name: "Dismiss")
        assertTitleDoesntExist(name: "2")
        assertTitleExists(name: "0")
    }
    
    // Note: works manually
    func test_segues_insertFull() {
        tapElement(name: "SegueInsertFullScreenCover")
        assertTitleExists(name: "1")
        
        tapElement(name: "Dismiss")
        assertTitleDoesntExist(name: "1")
        assertTitleExists(name: "2")
        
        tapElement(name: "Dismiss")
        assertTitleDoesntExist(name: "2")
        assertTitleExists(name: "0")
    }
    
    func test_dismiss_lastScreen() {
        tapElement(name: "DismissLastScreen")
        sleep(3)
        assertTitleDoesntExist(name: "4")
        assertTitleExists(name: "3")
    }
    
    func test_dismiss_lastEnvironment() {
        tapElement(name: "DismissLastEnvironment")
        sleep(3)
        assertTitleDoesntExist(name: "4")
        assertTitleDoesntExist(name: "3")
        assertTitleExists(name: "2")
    }
    
    func test_dismiss_lastPushStack() {
        tapElement(name: "DismissLastPushStack")
        sleep(3)
        assertTitleDoesntExist(name: "5")
        assertTitleDoesntExist(name: "4")
        assertTitleExists(name: "3")
    }
}
