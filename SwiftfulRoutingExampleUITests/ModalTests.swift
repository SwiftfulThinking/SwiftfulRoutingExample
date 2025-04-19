//
//  ModalTests.swift
//  SwiftfulRoutingExampleUITests
//
//  Created by Nick Sarno on 3/17/25.
//

import XCTest

final class ModalTests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = true
        app.launchArguments = ["UI_TESTING", "MODALS"]
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
    
    private func assertModalExists(name: String) {
        let titleElement = app.staticTexts["Modal_\(name)"]
        XCTAssertTrue(titleElement.exists)
    }
    
    private func assertModalDoesntExist(name: String) {
        let titleElement = app.staticTexts["Modal_\(name)"]
        XCTAssertFalse(titleElement.exists)
    }
    
    func test_showModal() {
        tapElement(name: "Modal1")
        assertModalExists(name: "1")
    }
    
    func test_showModals() {
        tapElement(name: "2Modals")
        assertModalExists(name: "Alpha")
        assertModalExists(name: "Beta")
    }
    
    func test_dismissModal() {
        tapElement(name: "Modal1")
        assertModalExists(name: "1")
        
        tapElement(name: "DismissModal")
        assertModalDoesntExist(name: "1")
    }
    
    func test_dismissModal_id() {
        tapElement(name: "DismissModalId1")
        assertModalExists(name: "1")

        sleep(3)
        assertModalDoesntExist(name: "1")
    }
    
    func test_dismissModal_id_underTop() {
        tapElement(name: "DismissModalId1_under")
        assertModalExists(name: "1")
        assertModalExists(name: "3")

        sleep(3)
        assertModalDoesntExist(name: "1")
        assertModalExists(name: "3")
    }
    
    func test_dismissModal_count() {
        tapElement(name: "Dismiss2Modals")
        assertModalExists(name: "1")
        assertModalExists(name: "2")
        assertModalExists(name: "3")
        sleep(3)
        assertModalExists(name: "1")
        assertModalDoesntExist(name: "2")
        assertModalDoesntExist(name: "3")
    }
    
    func test_dismissModal_upToId() {
        tapElement(name: "DismissModalsUpTo1")
        assertModalExists(name: "1")
        assertModalExists(name: "2")
        assertModalExists(name: "3")
        sleep(3)
        assertModalExists(name: "1")
        assertModalDoesntExist(name: "2")
        assertModalDoesntExist(name: "3")
    }
    
    func test_dismissModal_all() {
        tapElement(name: "DismissAllModals")
        assertModalExists(name: "1")
        assertModalExists(name: "2")
        assertModalExists(name: "3")
        sleep(3)
        assertModalDoesntExist(name: "1")
        assertModalDoesntExist(name: "2")
        assertModalDoesntExist(name: "3")
    }
}
