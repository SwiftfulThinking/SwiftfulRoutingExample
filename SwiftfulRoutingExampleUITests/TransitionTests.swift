//
//  TransitionTests.swift
//  SwiftfulRoutingExampleUITests
//
//  Created by Nick Sarno on 3/31/25.
//
import XCTest

final class TransitionTests: XCTestCase {

    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = true
        app.launchArguments = ["UI_TESTING", "TRANSITIONS"]
        app.launch()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
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
    
    func test_showTransition() {
        tapElement(name: "TransitionTrailing")
        assertTitleExists(name: "1")
    }
    
    func test_showTransitions() {
        tapElement(name: "2Transitions")
        assertTitleExists(name: "701")
        tapElement(name: "DismissTransition")
        assertTitleExists(name: "700")
    }
    
    func test_dismissTransition() {
        tapElement(name: "TransitionTrailing")
        assertTitleExists(name: "1")
        
        tapElement(name: "DismissTransition")
        assertTitleDoesntExist(name: "1")
    }
    
    func test_dismissTransition_id() {
        tapElement(name: "TransitionTrailing")
        assertTitleExists(name: "1")
        
        tapElement(name: "DismissTransitionId1")
        assertTitleDoesntExist(name: "1")
    }
     
    func test_dismissModal_count() {
        tapElement(name: "TransitionTrailing")
        assertTitleExists(name: "1")

        tapElement(name: "TransitionTrailing")
        assertTitleExists(name: "2")

        tapElement(name: "TransitionTrailing")
        assertTitleExists(name: "3")
        
        tapElement(name: "Dismiss2Transitions")
        assertTitleDoesntExist(name: "3")
        assertTitleDoesntExist(name: "2")
        assertTitleExists(name: "1")
    }

    func test_dismissModal_upToId() {
        tapElement(name: "TransitionTrailing")
        assertTitleExists(name: "1")

        tapElement(name: "TransitionTrailing")
        assertTitleExists(name: "2")

        tapElement(name: "TransitionTrailing")
        assertTitleExists(name: "3")
        
        tapElement(name: "DismissupToTransition1")
        assertTitleDoesntExist(name: "3")
        assertTitleDoesntExist(name: "2")
        assertTitleExists(name: "1")
    }
    
    func test_dismissModal_all() {
        tapElement(name: "TransitionTrailing")
        assertTitleExists(name: "1")

        tapElement(name: "TransitionTrailing")
        assertTitleExists(name: "2")

        tapElement(name: "TransitionTrailing")
        assertTitleExists(name: "3")
        
        tapElement(name: "DismissAllTransitions")
        assertTitleDoesntExist(name: "3")
        assertTitleDoesntExist(name: "2")
        assertTitleDoesntExist(name: "1")
        assertTitleExists(name: "0")
    }
    
}
