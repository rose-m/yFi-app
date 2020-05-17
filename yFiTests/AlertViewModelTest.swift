//
//  AlertViewTest.swift
//  yFiTests
//
//  Created by Michael Rose on 17.05.20.
//  Copyright © 2020 Coderose. All rights reserved.
//

import XCTest
import SwiftUI
@testable import yFi

class AlertViewModelTest: XCTestCase {
    
    var model: AlertViewModel!

    override func setUpWithError() throws {
        model = AlertViewModel()
    }

    func testClearState() {
        model.state = .clear
        XCTAssertEqual(model.icon, "icon-check")
        XCTAssertEqual(model.color, Color.green)
        XCTAssertEqual(model.content, LocalizedStringKey(stringLiteral: "WiFi working normally"))
    }
    
    func testAlertState() {
        model.state = .alert
        XCTAssertEqual(model.icon, "icon-warning")
        XCTAssertEqual(model.color, Color.yellow)
        XCTAssertEqual(model.content, LocalizedStringKey(stringLiteral: "WiFi rate dropped"))
    }
    
    func testReconnectingState() {
        model.state = .reconnecting
        XCTAssertEqual(model.icon, "icon-reconnect")
        XCTAssertEqual(model.color, Color.yellow)
        XCTAssertEqual(model.content, LocalizedStringKey(stringLiteral: "Reconnecting..."))
    }
    
    func testReconnectedState() {
        model.state = .reconnected
        XCTAssertEqual(model.icon, "icon-check")
        XCTAssertEqual(model.color, Color.green)
        XCTAssertEqual(model.content, LocalizedStringKey(stringLiteral: "Reconnected"))
    }
    
    func testFailedState() {
        model.state = .failed
        XCTAssertEqual(model.icon, "icon-failed")
        XCTAssertEqual(model.color, Color.red)
        XCTAssertEqual(model.content, LocalizedStringKey(stringLiteral: "WiFi issues persist"))
    }
}
