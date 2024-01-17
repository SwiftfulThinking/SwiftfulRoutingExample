//
//  SwiftfulRoutingExampleUITests.swift
//  SwiftfulRoutingExampleUITests
//
//  Created by Nick Sarno on 5/2/22.
//

import XCTest

// Notes:
// Tests will fail if the navBarTitle is hidden.
// Tests should be run on multiple OS (iOS 17, 16, 15, 14).
// iOS 16 & above uses NavigationStack
// iOS 15 & below uses NavigationView

class SwiftfulRoutingExampleUITests: XCTestCase {

    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = true
        app.launch()
    }

    override func tearDownWithError() throws {
    }
    
    private func tapElement(name: String, previousButtons: [String]) {
        let collectionViewsQuery = XCUIApplication().collectionViews
        let allButtonsWithThisName = collectionViewsQuery.buttons.matching(identifier: name)
        
        // For some reason, the way the UI lays out...
        // If pattern is sheet -> fullScreenCover -> x ,
        // then the 3rd screen needs to find the allElementsBoundByIndex.first instead of .last
        let matching = [["Sheet", "FullScreenCover"]]
        let lookForFirstElement = matching.contains(previousButtons.safeLast(2))
        let lastButton = lookForFirstElement ?
            allButtonsWithThisName.allElementsBoundByIndex.first :
            allButtonsWithThisName.allElementsBoundByIndex.last
        
        guard let lastButton else {
            XCTFail("Cannot find button named: \(name).")
            return
        }

        lastButton.tap()
        sleep(1)
    }
    
    private func tapBackButton(count: Int) {
        let navBar = app.navigationBars["#\(count)"]
        let button = navBar.buttons["#\(count - 1)"]
        button.tap()
        sleep(1)
        
        assertOnDismissExecuted(name: "#\(count - 1)", count: count)
    }
    
    private func tapElements(names: [String]) {
        var previousButtons: [String] = []
        for name in names {
            tapElement(name: name, previousButtons: previousButtons)
            previousButtons.append(name)
        }
    }
    
    private func assertNavigationBarExists(name: String) {
        let navBar = app.navigationBars[name]
        XCTAssertTrue(navBar.exists)
    }
    
    private func assertNavigationBarDoesntExist(name: String) {
        let navBar = app.navigationBars[name]
        XCTAssertTrue(!navBar.exists)
    }
    
    private func dismissScreens(previousButtons: [String]) {
        for (index, _) in previousButtons.enumerated() {
            tapElement(name: "Dismiss", previousButtons: previousButtons)
            
//            let newScreenNumber = (previousButtons.count - index)
//            assertOnDismissExecuted(name: "#\(newScreenNumber - 1)", count: newScreenNumber)
        }
    }
    
    
    
    private func assertOnDismissExecuted(name: String, count: Int) {
        let navBar = app.navigationBars[name]
        XCTAssertTrue(navBar.exists)
        
        let staticText = navBar.staticTexts["last_dismiss"]

        // Check if the staticText is present
        XCTAssert(staticText.exists)

        // Now assert that the text of the staticText is "A"
        XCTAssertEqual(staticText.label, "#\(count)")
    }
        
    // The below tests are:
    
    // Push Push Push
    // Push Push Sheet
    // Push Push FullScreenCover
    
    // Push Sheet Push
    // Push Sheet Sheet
    // Push Sheet FullScreenCover
    
    // Push FullScreenCover Push
    // Push FullScreenCover Sheet
    // Push FullScreenCover FullScreenCover
    
    // Sheet Push Push
    // Sheet Push Sheet
    // Sheet Push FullScreenCover
    
    // Sheet Sheet Push
    // Sheet Sheet Sheet
    // Sheet Sheet FullScreenCover
    
    // Sheet FullScreenCover Push
    // Sheet FullScreenCover Sheet
    // Sheet FullScreenCover FullScreenCover
    
    // FullScreenCover Push Push
    // FullScreenCover Push Sheet
    // FullScreenCover Push FullScreenCover

    // FullScreenCover Sheet Push
    // FullScreenCover Sheet Sheet
    // FullScreenCover Sheet FullScreenCover

    // FullScreenCover FullScreenCover Push
    // FullScreenCover FullScreenCover Sheet
    // FullScreenCover FullScreenCover FullScreenCover
    
    // PushStack, PushStack, PushStack
    // PushStack, Sheet, FullScreenCover
    // Sheet, FullScreenCover, PushStack
    
    // TODO:
    // More PushStack variations
    // Super tests with random buttons
    
    func test_push_back_push_back_push_back() {
        let names = ["Push"]
        tapElements(names: names)
        assertNavigationBarExists(name: "#\(names.count)")
        tapBackButton(count: names.count)

        tapElements(names: names)
        assertNavigationBarExists(name: "#\(names.count)")
        tapBackButton(count: names.count)

        tapElements(names: names)
        assertNavigationBarExists(name: "#\(names.count)")
        tapBackButton(count: names.count)

        assertNavigationBarExists(name: "#0")
        assertNavigationBarDoesntExist(name: "#\(names.count)")
    }
        
    func test_segues_push_push_push() {
        let names = ["Push", "Push", "Push"]
        tapElements(names: names)
        assertNavigationBarExists(name: "#\(names.count)")
        dismissScreens(previousButtons: names)
        assertNavigationBarExists(name: "#0")
        assertNavigationBarDoesntExist(name: "#\(names.count)")
    }
        
    func test_segues_push_push_sheet() {
        let names = ["Push", "Push", "Sheet"]
        tapElements(names: names)
        assertNavigationBarExists(name: "#\(names.count)")
        dismissScreens(previousButtons: names)
        assertNavigationBarExists(name: "#0")
        assertNavigationBarDoesntExist(name: "#\(names.count)")
    }
    
    func test_segues_push_push_fullScreenCover() {
        let names = ["Push", "Push", "FullScreenCover"]
        tapElements(names: names)
        assertNavigationBarExists(name: "#\(names.count)")
        dismissScreens(previousButtons: names)
        assertNavigationBarExists(name: "#0")
        assertNavigationBarDoesntExist(name: "#\(names.count)")
    }
    
    func test_segues_push_sheet_push() {
        let names = ["Push", "Sheet", "Push"]
        tapElements(names: names)
        assertNavigationBarExists(name: "#\(names.count)")
        dismissScreens(previousButtons: names)
        assertNavigationBarExists(name: "#0")
        assertNavigationBarDoesntExist(name: "#\(names.count)")
    }
    
    func test_segues_push_sheet_sheet() {
        let names = ["Push", "Sheet", "Sheet"]
        tapElements(names: names)
        assertNavigationBarExists(name: "#\(names.count)")
        dismissScreens(previousButtons: names)
        assertNavigationBarExists(name: "#0")
        assertNavigationBarDoesntExist(name: "#\(names.count)")
    }
    
    func test_segues_push_sheet_fullScreenCover() {
        let names = ["Push", "Sheet", "FullScreenCover"]
        tapElements(names: names)
        assertNavigationBarExists(name: "#\(names.count)")
        dismissScreens(previousButtons: names)
        assertNavigationBarExists(name: "#0")
        assertNavigationBarDoesntExist(name: "#\(names.count)")
    }
    
    func test_segues_push_fullScreenCover_push() {
        let names = ["Push", "FullScreenCover", "Push"]
        tapElements(names: names)
        assertNavigationBarExists(name: "#\(names.count)")
        dismissScreens(previousButtons: names)
        assertNavigationBarExists(name: "#0")
        assertNavigationBarDoesntExist(name: "#\(names.count)")
    }
    
    func test_segues_push_fullScreenCover_sheet() {
        let names = ["Push", "FullScreenCover", "Sheet"]
        tapElements(names: names)
        assertNavigationBarExists(name: "#\(names.count)")
        dismissScreens(previousButtons: names)
        assertNavigationBarExists(name: "#0")
        assertNavigationBarDoesntExist(name: "#\(names.count)")
    }
    
    func test_segues_push_fullScreenCover_fullScreenCover() {
        let names = ["Push", "FullScreenCover", "FullScreenCover"]
        tapElements(names: names)
        assertNavigationBarExists(name: "#\(names.count)")
        dismissScreens(previousButtons: names)
        assertNavigationBarExists(name: "#0")
        assertNavigationBarDoesntExist(name: "#\(names.count)")
    }

    func test_segues_sheet_push_push() {
        let names = ["Sheet", "Push", "Push"]
        tapElements(names: names)
        assertNavigationBarExists(name: "#\(names.count)")
        dismissScreens(previousButtons: names)
        assertNavigationBarExists(name: "#0")
        assertNavigationBarDoesntExist(name: "#\(names.count)")
    }
    
    func test_segues_sheet_push_sheet() {
        let names = ["Sheet", "Push", "Sheet"]
        tapElements(names: names)
        assertNavigationBarExists(name: "#\(names.count)")
        dismissScreens(previousButtons: names)
        assertNavigationBarExists(name: "#0")
        assertNavigationBarDoesntExist(name: "#\(names.count)")
    }
    
    func test_segues_sheet_push_fullScreenCover() {
        let names = ["Sheet", "Push", "FullScreenCover"]
        tapElements(names: names)
        assertNavigationBarExists(name: "#\(names.count)")
        dismissScreens(previousButtons: names)
        assertNavigationBarExists(name: "#0")
        assertNavigationBarDoesntExist(name: "#\(names.count)")
    }
    
    func test_segues_sheet_sheet_push() {
        let names = ["Sheet", "Sheet", "Push"]
        tapElements(names: names)
        assertNavigationBarExists(name: "#\(names.count)")
        dismissScreens(previousButtons: names)
        assertNavigationBarExists(name: "#0")
        assertNavigationBarDoesntExist(name: "#\(names.count)")
    }
    
    func test_segues_sheet_sheet_sheet() {
        let names = ["Sheet", "Sheet", "Sheet"]
        tapElements(names: names)
        assertNavigationBarExists(name: "#\(names.count)")
        dismissScreens(previousButtons: names)
        assertNavigationBarExists(name: "#0")
        assertNavigationBarDoesntExist(name: "#\(names.count)")
    }
    
    func test_segues_sheet_sheet_fullScreenCover() {
        let names = ["Sheet", "Sheet", "FullScreenCover"]
        tapElements(names: names)
        assertNavigationBarExists(name: "#\(names.count)")
        dismissScreens(previousButtons: names)
        assertNavigationBarExists(name: "#0")
        assertNavigationBarDoesntExist(name: "#\(names.count)")
    }
    
    func test_segues_sheet_fullScreenCover_push() {
        let names = ["Sheet", "FullScreenCover", "Push"]
        tapElements(names: names)
        assertNavigationBarExists(name: "#\(names.count)")
        dismissScreens(previousButtons: names)
        assertNavigationBarExists(name: "#0")
        assertNavigationBarDoesntExist(name: "#\(names.count)")
    }
    
    func test_segues_sheet_fullScreenCover_sheet() {
        let names = ["Sheet", "FullScreenCover", "Sheet"]
        tapElements(names: names)
        assertNavigationBarExists(name: "#\(names.count)")
        dismissScreens(previousButtons: names)
        assertNavigationBarExists(name: "#0")
        assertNavigationBarDoesntExist(name: "#\(names.count)")
    }
    
    func test_segues_sheet_fullScreenCover_fullScreenCover() {
        let names = ["Sheet", "FullScreenCover", "FullScreenCover"]
        tapElements(names: names)
        assertNavigationBarExists(name: "#\(names.count)")
        dismissScreens(previousButtons: names)
        assertNavigationBarExists(name: "#0")
        assertNavigationBarDoesntExist(name: "#\(names.count)")
    }
    
    func test_segues_fullScreenCover_push_push() {
        let names = ["FullScreenCover", "Push", "Push"]
        tapElements(names: names)
        assertNavigationBarExists(name: "#\(names.count)")
        dismissScreens(previousButtons: names)
        assertNavigationBarExists(name: "#0")
        assertNavigationBarDoesntExist(name: "#\(names.count)")
    }
    
    func test_segues_fullScreenCover_push_sheet() {
        let names = ["FullScreenCover", "Push", "Sheet"]
        tapElements(names: names)
        assertNavigationBarExists(name: "#\(names.count)")
        dismissScreens(previousButtons: names)
        assertNavigationBarExists(name: "#0")
        assertNavigationBarDoesntExist(name: "#\(names.count)")
    }
    
    func test_segues_fullScreenCover_push_fullScreenCover() {
        let names = ["FullScreenCover", "Push", "FullScreenCover"]
        tapElements(names: names)
        assertNavigationBarExists(name: "#\(names.count)")
        dismissScreens(previousButtons: names)
        assertNavigationBarExists(name: "#0")
        assertNavigationBarDoesntExist(name: "#\(names.count)")
    }

    // Note: this test fails for some reason, but succeeds when manually tested.
    func test_segues_fullScreenCover_sheet_push() {
        let names = ["FullScreenCover", "Sheet", "Push"]
        tapElements(names: names)
        
        // Start: For some reason, this makes the test pass
//        let tablesQuery = XCUIApplication().tables
//        let element = tablesQuery.cells["Sheet"].children(matching: .other).element(boundBy: 0).children(matching: .other).element
//        element.swipeDown()
//        element.tap()
        // End
        
        assertNavigationBarExists(name: "#\(names.count)")
        dismissScreens(previousButtons: names)
        assertNavigationBarExists(name: "#0")
        assertNavigationBarDoesntExist(name: "#\(names.count)")
    }
    
    func test_segues_fullScreenCover_sheet_sheet() {
        let names = ["FullScreenCover", "Sheet", "Sheet"]
        tapElements(names: names)
        assertNavigationBarExists(name: "#\(names.count)")
        dismissScreens(previousButtons: names)
        assertNavigationBarExists(name: "#0")
        assertNavigationBarDoesntExist(name: "#\(names.count)")
    }
    
    func test_segues_fullScreenCover_sheet_fullScreenCover() {
        let names = ["FullScreenCover", "Sheet", "FullScreenCover"]
        tapElements(names: names)
        assertNavigationBarExists(name: "#\(names.count)")
        dismissScreens(previousButtons: names)
        assertNavigationBarExists(name: "#0")
        assertNavigationBarDoesntExist(name: "#\(names.count)")
    }
    
    func test_segues_fullScreenCover_fullScreenCover_push() {
        let names = ["FullScreenCover", "FullScreenCover", "Push"]
        tapElements(names: names)
        assertNavigationBarExists(name: "#\(names.count)")
        dismissScreens(previousButtons: names)
        assertNavigationBarExists(name: "#0")
        assertNavigationBarDoesntExist(name: "#\(names.count)")
    }
    
    func test_segues_fullScreenCover_fullScreenCover_sheet() {
        let names = ["FullScreenCover", "FullScreenCover", "Sheet"]
        tapElements(names: names)
        assertNavigationBarExists(name: "#\(names.count)")
        dismissScreens(previousButtons: names)
        assertNavigationBarExists(name: "#0")
        assertNavigationBarDoesntExist(name: "#\(names.count)")
    }
    
    func test_segues_fullScreenCover_fullScreenCover_fullScreenCover() {
        let names = ["FullScreenCover", "FullScreenCover", "FullScreenCover"]
        tapElements(names: names)
        assertNavigationBarExists(name: "#\(names.count)")
        dismissScreens(previousButtons: names)
        assertNavigationBarExists(name: "#0")
        assertNavigationBarDoesntExist(name: "#\(names.count)")
    }
    
    func test_segues_pushStack_pushStack_pushStack() {
        if #available(iOS 16, *) {
            let names = ["Push Stack (3x)", "Push Stack (3x)", "Push Stack (3x)"]
            tapElements(names: names)
            assertNavigationBarExists(name: "#\(names.count * 3)")
            tapElements(names: ["Dismiss Screen Stack"])
            assertNavigationBarExists(name: "#0")
        assertNavigationBarDoesntExist(name: "#\(names.count)")
        }
    }

    func test_segues_pushStack_sheet_fullScreenCover() {
        if #available(iOS 16, *) {
            let names = ["Push Stack (3x)", "Sheet", "FullScreenCover"]
            tapElements(names: names)
            assertNavigationBarExists(name: "#5")
            dismissScreens(previousButtons: ["Sheet", "FullScreenCover"])
            tapElements(names: ["Dismiss Screen Stack"])
            assertNavigationBarExists(name: "#0")
        assertNavigationBarDoesntExist(name: "#\(names.count)")
        }
    }
    
    func test_segues_sheet_fullScreenCover_pushStack() {
        // WARNING: works manually, but test fails on iOS 16.0+?
        if #available(iOS 16, *) {
            let names = ["Sheet", "FullScreenCover", "Push Stack (3x)"]
            tapElements(names: names)
            assertNavigationBarExists(name: "#5")
            tapElements(names: ["Dismiss Screen Stack"])
            assertNavigationBarExists(name: "#2")
            dismissScreens(previousButtons: ["Sheet", "FullScreenCover"])
            assertNavigationBarExists(name: "#0")
            assertNavigationBarDoesntExist(name: "#\(names.count)")
        }
    }
}

extension Array {
    func safeLast(_ count: Int) -> Array<Element> {
        let validCount = Swift.max(0, Swift.min(count, self.count))
        let startIndex = self.count - validCount
        return Array(self[startIndex..<self.endIndex])
    }
}
