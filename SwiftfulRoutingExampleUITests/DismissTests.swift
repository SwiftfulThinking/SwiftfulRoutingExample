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

    // Button identifiers are suffixed with the screen number they render on
    // (ie. "Button_Push_0"), so every query resolves to exactly one element
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

    func test_dismiss_push() {
        tapElement(name: "Push", screen: 0)
        assertTitleExists(name: "1")
        tapElement(name: "Dismiss", screen: 1)
        assertTitleDoesntExist(name: "1")
    }

    func test_dismiss_sheet() {
        tapElement(name: "Sheet", screen: 0)
        assertTitleExists(name: "1")
        tapElement(name: "Dismiss", screen: 1)
        assertTitleDoesntExist(name: "1")
    }

    func test_dismiss_full() {
        tapElement(name: "FullScreenCover", screen: 0)
        assertTitleExists(name: "1")
        tapElement(name: "Dismiss", screen: 1)
        assertTitleDoesntExist(name: "1")
    }

    func test_dismissId_push() {
        for screen in 0..<3 {
            tapElement(name: "Push", screen: screen)
        }
        assertTitleExists(name: "3")
        tapElement(name: "DismissId2", screen: 3)
        assertTitleDoesntExist(name: "3")
        assertTitleExists(name: "1")
    }

    func test_dismissId_sheet() {
        for screen in 0..<3 {
            tapElement(name: "Sheet", screen: screen)
        }
        assertTitleExists(name: "3")
        tapElement(name: "DismissId2", screen: 3)
        assertTitleDoesntExist(name: "3")
        assertTitleExists(name: "1")
    }

    func test_dismissId_full() {
        for screen in 0..<3 {
            tapElement(name: "FullScreenCover", screen: screen)
        }
        assertTitleExists(name: "3")
        tapElement(name: "DismissId2", screen: 3)
        assertTitleDoesntExist(name: "3")
        assertTitleExists(name: "1")
    }

    func test_dismissId_sheetFullPush() {
        tapElement(name: "Sheet", screen: 0)
        tapElement(name: "FullScreenCover", screen: 1)
        tapElement(name: "Push", screen: 2)
        assertTitleExists(name: "3")
        tapElement(name: "DismissId2", screen: 3)
        assertTitleDoesntExist(name: "3")
        assertTitleExists(name: "1")
    }

    func test_dismissId_pushFullSheet() {
        tapElement(name: "Push", screen: 0)
        tapElement(name: "FullScreenCover", screen: 1)
        tapElement(name: "Sheet", screen: 2)
        assertTitleExists(name: "3")
        tapElement(name: "DismissId2", screen: 3)
        assertTitleDoesntExist(name: "3")
        assertTitleExists(name: "1")
    }

    func test_dismissTo_push() {
        for screen in 0..<3 {
            tapElement(name: "Push", screen: screen)
        }
        assertTitleExists(name: "3")
        tapElement(name: "DismissTo1", screen: 3)
        assertTitleDoesntExist(name: "3")
        assertTitleExists(name: "1")
    }

    func test_dismissTo_sheet() {
        for screen in 0..<3 {
            tapElement(name: "Sheet", screen: screen)
        }
        assertTitleExists(name: "3")
        tapElement(name: "DismissTo1", screen: 3)
        assertTitleDoesntExist(name: "3")
        assertTitleExists(name: "1")
    }

    func test_dismissTo_full() {
        for screen in 0..<3 {
            tapElement(name: "FullScreenCover", screen: screen)
        }
        assertTitleExists(name: "3")
        tapElement(name: "DismissTo1", screen: 3)
        assertTitleDoesntExist(name: "3")
        assertTitleExists(name: "1")
    }

    func test_dismissTo_sheetFullPush() {
        tapElement(name: "Sheet", screen: 0)
        tapElement(name: "FullScreenCover", screen: 1)
        tapElement(name: "Push", screen: 2)
        assertTitleExists(name: "3")
        tapElement(name: "DismissTo1", screen: 3)
        assertTitleDoesntExist(name: "3")
        assertTitleExists(name: "1")
    }

    func test_dismissTo_pushFullSheet() {
        tapElement(name: "Push", screen: 0)
        tapElement(name: "FullScreenCover", screen: 1)
        tapElement(name: "Sheet", screen: 2)
        assertTitleExists(name: "3")
        tapElement(name: "DismissTo1", screen: 3)
        assertTitleDoesntExist(name: "3")
        assertTitleExists(name: "1")
    }

    func test_dismissCount_push() {
        for screen in 0..<3 {
            tapElement(name: "Push", screen: screen)
        }
        assertTitleExists(name: "3")
        tapElement(name: "DismissCount2", screen: 3)
        assertTitleDoesntExist(name: "3")
        assertTitleExists(name: "1")
    }

    func test_dismissCount_sheet() {
        for screen in 0..<3 {
            tapElement(name: "Sheet", screen: screen)
        }
        assertTitleExists(name: "3")
        tapElement(name: "DismissCount2", screen: 3)
        assertTitleDoesntExist(name: "3")
        assertTitleExists(name: "1")
    }

    func test_dismissCount_full() {
        for screen in 0..<3 {
            tapElement(name: "FullScreenCover", screen: screen)
        }
        assertTitleExists(name: "3")
        tapElement(name: "DismissCount2", screen: 3)
        assertTitleDoesntExist(name: "3")
        assertTitleExists(name: "1")
    }

    func test_dismissCount_sheetFullPush() {
        tapElement(name: "Sheet", screen: 0)
        tapElement(name: "FullScreenCover", screen: 1)
        tapElement(name: "Push", screen: 2)
        assertTitleExists(name: "3")
        tapElement(name: "DismissCount2", screen: 3)
        assertTitleDoesntExist(name: "3")
        assertTitleExists(name: "1")
    }

    func test_dismissCount_pushFullSheet() {
        tapElement(name: "Push", screen: 0)
        tapElement(name: "FullScreenCover", screen: 1)
        tapElement(name: "Sheet", screen: 2)
        assertTitleExists(name: "3")
        tapElement(name: "DismissCount2", screen: 3)
        assertTitleDoesntExist(name: "3")
        assertTitleExists(name: "1")
    }

    func test_dismissPushStack_push() {
        for screen in 0..<5 {
            tapElement(name: "Push", screen: screen)
        }
        assertTitleExists(name: "5")
        tapElement(name: "DismissStack", screen: 5)
        assertTitleDoesntExist(name: "5")
        assertTitleDoesntExist(name: "1")
        assertTitleExists(name: "0")
    }

    func test_dismissCount_sheetPush() {
        tapElement(name: "Sheet", screen: 0)
        tapElement(name: "Push", screen: 1)
        tapElement(name: "Push", screen: 2)
        tapElement(name: "Push", screen: 3)
        tapElement(name: "Push", screen: 4)
        assertTitleExists(name: "5")
        tapElement(name: "DismissStack", screen: 5)
        assertTitleDoesntExist(name: "5")
        assertTitleDoesntExist(name: "2")
        assertTitleExists(name: "1")
    }

    func test_dismissEnvironment_sheet() {
        tapElement(name: "Sheet", screen: 0)
        tapElement(name: "Push", screen: 1)

        tapElement(name: "Sheet", screen: 2)
        tapElement(name: "Push", screen: 3)

        tapElement(name: "Sheet", screen: 4)
        tapElement(name: "Push", screen: 5)

        assertTitleExists(name: "6")
        tapElement(name: "DismissEnvironment", screen: 6)
        assertTitleDoesntExist(name: "6")

        assertTitleExists(name: "4")
        tapElement(name: "DismissEnvironment", screen: 4)
        assertTitleDoesntExist(name: "4")

        assertTitleExists(name: "2")
        tapElement(name: "DismissEnvironment", screen: 2)
        assertTitleDoesntExist(name: "2")

        assertTitleExists(name: "0")
    }

    func test_dismissEnvironment_full() {
        tapElement(name: "FullScreenCover", screen: 0)
        tapElement(name: "Push", screen: 1)

        tapElement(name: "FullScreenCover", screen: 2)
        tapElement(name: "Push", screen: 3)

        tapElement(name: "FullScreenCover", screen: 4)
        tapElement(name: "Push", screen: 5)

        assertTitleExists(name: "6")
        tapElement(name: "DismissEnvironment", screen: 6)
        assertTitleDoesntExist(name: "6")

        assertTitleExists(name: "4")
        tapElement(name: "DismissEnvironment", screen: 4)
        assertTitleDoesntExist(name: "4")

        assertTitleExists(name: "2")
        tapElement(name: "DismissEnvironment", screen: 2)
        assertTitleDoesntExist(name: "2")

        assertTitleExists(name: "0")
    }

    func test_dismissAll() {
        tapElement(name: "Push", screen: 0)
        tapElement(name: "Sheet", screen: 1)
        tapElement(name: "Push", screen: 2)
        tapElement(name: "Sheet", screen: 3)
        tapElement(name: "Push", screen: 4)

        assertTitleExists(name: "5")
        tapElement(name: "DismissAll", screen: 5)
        assertTitleDoesntExist(name: "5")
        assertTitleDoesntExist(name: "2")
        assertTitleExists(name: "0")
    }

}
