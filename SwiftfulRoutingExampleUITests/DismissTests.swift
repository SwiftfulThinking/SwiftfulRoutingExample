//
//  DismissTests.swift
//  SwiftfulRoutingExampleUITests
//
//  Created by Nick Sarno on 3/7/25.
//

import XCTest

final class DismissTests: XCTestCase {

    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = true
        app.launchArguments = ["UI_TESTING", "DISMISSING"]
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
    
    func test_dismiss_push() {
        tapElement(name: "Push")
        assertTitleExists(name: "1")
        tapElement(name: "Dismiss")
        assertTitleDoesntExist(name: "1")
    }
    
    func test_dismiss_sheet() {
        tapElement(name: "Sheet")
        assertTitleExists(name: "1")
        tapElement(name: "Dismiss")
        assertTitleDoesntExist(name: "1")
    }
    
    func test_dismiss_full() {
        tapElement(name: "FullScreenCover")
        assertTitleExists(name: "1")
        tapElement(name: "Dismiss")
        assertTitleDoesntExist(name: "1")
    }
    
    func test_dismissId_push() {
        for _ in 0..<3 {
            tapElement(name: "Push")
        }
        assertTitleExists(name: "3")
        tapElement(name: "DismissId2")
        assertTitleDoesntExist(name: "3")
        assertTitleExists(name: "1")
    }
    
    func test_dismissId_sheet() {
        for _ in 0..<3 {
            tapElement(name: "Sheet")
        }
        assertTitleExists(name: "3")
        tapElement(name: "DismissId2")
        assertTitleDoesntExist(name: "3")
        assertTitleExists(name: "1")
    }
    
    func test_dismissId_full() {
        for _ in 0..<3 {
            tapElement(name: "FullScreenCover")
        }
        assertTitleExists(name: "3")
        tapElement(name: "DismissId2")
        assertTitleDoesntExist(name: "3")
        assertTitleExists(name: "1")
    }
    
    func test_dismissId_sheetFullPush() {
        tapElement(name: "Sheet")
        tapElement(name: "FullScreenCover")
        tapElement(name: "Push")
        assertTitleExists(name: "3")
        tapElement(name: "DismissId2")
        assertTitleDoesntExist(name: "3")
        assertTitleExists(name: "1")
    }
    
    func test_dismissId_pushFullSheet() {
        tapElement(name: "Push")
        tapElement(name: "FullScreenCover")
        tapElement(name: "Sheet")
        assertTitleExists(name: "3")
        tapElement(name: "DismissId2")
        assertTitleDoesntExist(name: "3")
        assertTitleExists(name: "1")
    }
    
    func test_dismissTo_push() {
        for _ in 0..<3 {
            tapElement(name: "Push")
        }
        assertTitleExists(name: "3")
        tapElement(name: "DismissTo1")
        assertTitleDoesntExist(name: "3")
        assertTitleExists(name: "1")
    }
    
    func test_dismissTo_sheet() {
        for _ in 0..<3 {
            tapElement(name: "Sheet")
        }
        assertTitleExists(name: "3")
        tapElement(name: "DismissTo1")
        assertTitleDoesntExist(name: "3")
        assertTitleExists(name: "1")
    }
    
    func test_dismissTo_full() {
        for _ in 0..<3 {
            tapElement(name: "FullScreenCover")
        }
        assertTitleExists(name: "3")
        tapElement(name: "DismissTo1")
        assertTitleDoesntExist(name: "3")
        assertTitleExists(name: "1")
    }
    
    func test_dismissTo_sheetFullPush() {
        tapElement(name: "Sheet")
        tapElement(name: "FullScreenCover")
        tapElement(name: "Push")
        assertTitleExists(name: "3")
        tapElement(name: "DismissTo1")
        assertTitleDoesntExist(name: "3")
        assertTitleExists(name: "1")
    }
    
    func test_dismissTo_pushFullSheet() {
        tapElement(name: "Push")
        tapElement(name: "FullScreenCover")
        tapElement(name: "Sheet")
        assertTitleExists(name: "3")
        tapElement(name: "DismissTo1")
        assertTitleDoesntExist(name: "3")
        assertTitleExists(name: "1")
    }
    
    func test_dismissCount_push() {
        for _ in 0..<3 {
            tapElement(name: "Push")
        }
        assertTitleExists(name: "3")
        tapElement(name: "DismissCount2")
        assertTitleDoesntExist(name: "3")
        assertTitleExists(name: "1")
    }
    
    func test_dismissCount_sheet() {
        for _ in 0..<3 {
            tapElement(name: "Sheet")
        }
        assertTitleExists(name: "3")
        tapElement(name: "DismissCount2")
        assertTitleDoesntExist(name: "3")
        assertTitleExists(name: "1")
    }
    
    func test_dismissCount_full() {
        for _ in 0..<3 {
            tapElement(name: "FullScreenCover")
        }
        assertTitleExists(name: "3")
        tapElement(name: "DismissCount2")
        assertTitleDoesntExist(name: "3")
        assertTitleExists(name: "1")
    }
    
    func test_dismissCount_sheetFullPush() {
        tapElement(name: "Sheet")
        tapElement(name: "FullScreenCover")
        tapElement(name: "Push")
        assertTitleExists(name: "3")
        tapElement(name: "DismissCount2")
        assertTitleDoesntExist(name: "3")
        assertTitleExists(name: "1")
    }
    
    func test_dismissCount_pushFullSheet() {
        tapElement(name: "Push")
        tapElement(name: "FullScreenCover")
        tapElement(name: "Sheet")
        assertTitleExists(name: "3")
        tapElement(name: "DismissCount2")
        assertTitleDoesntExist(name: "3")
        assertTitleExists(name: "1")
    }

    func test_dismissPushStack_push() {
        tapElement(name: "Push")
        tapElement(name: "Push")
        tapElement(name: "Push")
        tapElement(name: "Push")
        tapElement(name: "Push")
        assertTitleExists(name: "5")
        tapElement(name: "DismissStack")
        assertTitleDoesntExist(name: "5")
        assertTitleDoesntExist(name: "1")
        assertTitleExists(name: "0")
    }
    
    func test_dismissCount_sheetPush() {
        tapElement(name: "Sheet")
        tapElement(name: "Push")
        tapElement(name: "Push")
        tapElement(name: "Push")
        tapElement(name: "Push")
        assertTitleExists(name: "5")
        tapElement(name: "DismissStack")
        assertTitleDoesntExist(name: "5")
        assertTitleDoesntExist(name: "2")
        assertTitleExists(name: "1")
    }
    
    func test_dismissEnvironment_sheet() {
        tapElement(name: "Sheet")
        tapElement(name: "Push")
        
        tapElement(name: "Sheet")
        tapElement(name: "Push")
        
        tapElement(name: "Sheet")
        tapElement(name: "Push")
        
        assertTitleExists(name: "6")
        tapElement(name: "DismissEnvironment")
        assertTitleDoesntExist(name: "6")
        
        assertTitleExists(name: "4")
        tapElement(name: "DismissEnvironment")
        assertTitleDoesntExist(name: "4")

        assertTitleExists(name: "2")
        tapElement(name: "DismissEnvironment")
        assertTitleDoesntExist(name: "2")
        
        assertTitleExists(name: "0")
    }
    
    func test_dismissEnvironment_full() {
        tapElement(name: "FullScreenCover")
        tapElement(name: "Push")
        
        tapElement(name: "FullScreenCover")
        tapElement(name: "Push")
        
        tapElement(name: "FullScreenCover")
        tapElement(name: "Push")
        
        assertTitleExists(name: "6")
        tapElement(name: "DismissEnvironment")
        assertTitleDoesntExist(name: "6")
        
        assertTitleExists(name: "4")
        tapElement(name: "DismissEnvironment")
        assertTitleDoesntExist(name: "4")

        assertTitleExists(name: "2")
        tapElement(name: "DismissEnvironment")
        assertTitleDoesntExist(name: "2")
        
        assertTitleExists(name: "0")
    }
    
    func test_dismissAll() {
        tapElement(name: "Push")
        tapElement(name: "Sheet")
        tapElement(name: "Push")
        tapElement(name: "Sheet")
        tapElement(name: "Push")

        assertTitleExists(name: "5")
        tapElement(name: "DismissAll")
        assertTitleDoesntExist(name: "5")
        assertTitleDoesntExist(name: "2")
        assertTitleExists(name: "0")
    }
    
}
