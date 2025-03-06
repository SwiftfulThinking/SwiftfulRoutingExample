//
//  SegueTests.swift
//  SwiftfulRoutingExampleUITests
//
//  Created by Nick Sarno on 3/4/25.
//

import XCTest

final class SegueTests: XCTestCase {

    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = true
        app.launchArguments = ["UI_TESTING", "SEGUES"]
        app.launch()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    private func tapElements(names: [String]) {
        for name in names {
            let buttons = app.collectionViews.buttons.matching(identifier: "Button_\(name)")
//            let buttons = app.buttons.matching(identifier: "Button_\(name)")
            
            let lookForFirstElement = name == "FullScreenCover"

            if let button = lookForFirstElement ?
                buttons.allElementsBoundByIndex.first :
                buttons.allElementsBoundByIndex.last {
                button.tap()
                sleep(1)
            }
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
        
    private func tapDismiss(names: [String]) {
        for name in names.reversed() {
            let buttons = app.collectionViews.buttons.matching(identifier: "Button_Dismiss")
//            let buttons = app.buttons.matching(identifier: "Button_Dismiss")
            let lookForFirstElement = name == "FullScreenCover"

            if let button = lookForFirstElement ?
                buttons.allElementsBoundByIndex.first :
                buttons.allElementsBoundByIndex.last {
                button.tap()
                sleep(1)
            }
        }
    }
        
    private func testSegues(names: [String]) {
        tapElements(names: names)
        assertTitleExists(name: "\(names.count)")
        tapDismiss(names: names)
        assertTitleExists(name: "0")
        assertTitleDoesntExist(name: "\(names.count)")
    }

    func test_push_push_push() {
        testSegues(names: ["Push", "Push", "Push"])
    }
    
    func test_push_push_sheet() {
        testSegues(names: ["Push", "Push", "Sheet"])
    }
    
    func test_push_push_full() {
        testSegues(names: ["Push", "Push", "FullScreenCover"])
    }
    
    func test_push_sheet_push() {
        testSegues(names: ["Push", "Sheet", "Push"])
    }
    
    func test_push_sheet_sheet() {
        testSegues(names: ["Push", "Sheet", "Sheet"])
    }
    
    func test_push_sheet_full() {
        testSegues(names: ["Push", "Sheet", "FullScreenCover"])
    }
    
    func test_push_full_push() {
        testSegues(names: ["Push", "FullScreenCover", "Push"])
    }
    
    func test_push_full_sheet() {
        testSegues(names: ["Push", "FullScreenCover", "Sheet"])
    }
    
    func test_push_full_full() {
        testSegues(names: ["Push", "FullScreenCover", "FullScreenCover"])
    }
    
    func test_sheet_push_push() {
        testSegues(names: ["Sheet", "Push", "Push"])
    }
    
    func test_sheet_push_sheet() {
        testSegues(names: ["Sheet", "Push", "Sheet"])
    }
    
    func test_sheet_push_full() {
        testSegues(names: ["Sheet", "Push", "FullScreenCover"])
    }
    
    func test_sheet_sheet_push() {
        testSegues(names: ["Sheet", "Sheet", "Push"])
    }
    
    func test_sheet_sheet_full() {
        testSegues(names: ["Sheet", "Sheet", "FullScreenCover"])
    }
    
    func test_sheet_full_sheet() {
        testSegues(names: ["Sheet", "FullScreenCover", "Sheet"])
    }
    
    func test_sheet_full_full() {
        testSegues(names: ["Sheet", "FullScreenCover", "FullScreenCover"])
    }
    
    // push sheet full
    // sheet sheet full
    // sheet full full
    
    func test_full_push_push() {
        testSegues(names: ["FullScreenCover", "Push", "Push"])
    }
    
    func test_full_push_sheet() {
        testSegues(names: ["FullScreenCover", "Push", "Sheet"])
    }
    
    func test_full_push_full() {
        testSegues(names: ["FullScreenCover", "Push", "FullScreenCover"])
    }
    
    func test_full_sheet_push() {
        testSegues(names: ["FullScreenCover", "Sheet", "Push"])
    }
    
    func test_full_sheet_sheet() {
        testSegues(names: ["FullScreenCover", "Sheet", "Sheet"])
    }
    
    // Note: This test fails, idk why. Works manually.
    func test_full_sheet_full() {
        testSegues(names: ["FullScreenCover", "Sheet", "FullScreenCover"])
    }
    
    func test_full_full_push() {
        testSegues(names: ["FullScreenCover", "FullScreenCover", "Push"])
    }
    
    func test_full_full_sheet() {
        testSegues(names: ["FullScreenCover", "FullScreenCover", "Sheet"])
    }
    
    func test_full_full_full() {
        testSegues(names: ["FullScreenCover", "FullScreenCover", "FullScreenCover"])
    }
    
}
