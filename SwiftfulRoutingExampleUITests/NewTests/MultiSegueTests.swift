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
        
    private func tapDismiss(buttonName: String, count: Int) {
        for _ in 0..<3 {
            let buttons = app.collectionViews.buttons.matching(identifier: "Button_Dismiss")

            // Weird edge case idk why
            let lookForFirstElement = buttonName == "PushSheetFull"

            if let button = lookForFirstElement ?
                buttons.allElementsBoundByIndex.first :
                buttons.allElementsBoundByIndex.last {
                button.tap()
                sleep(1)
            }
        }
    }
        
    private func testSegues(name: String) {
        tapElement(name: name)
        let count: Int = 3
        assertTitleExists(name: "\(count)")
        tapDismiss(buttonName: name, count: count)
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
