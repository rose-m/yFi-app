//
//  AlertingControllerTest.swift
//  yFiTests
//
//  Created by Michael Rose on 17.05.20.
//  Copyright © 2020 Coderose. All rights reserved.
//

import XCTest
import Combine
@testable import yFi

class AlertingControllerTests : XCTestCase {
    
    var currentRate: CurrentValueSubject<Double, Never>!
    var reconnectCallback: ((Bool) -> Void)? = nil
    var onReconnect: OnReconnectCallback!
    var currentLimit: CurrentValueSubject<Int, Never>!
    var currentAction: CurrentValueSubject<LowRateAction, Never>!
    
    var controller: AlertingController!
    
    override func setUpWithError() throws {
        currentRate = CurrentValueSubject<Double, Never>(0)
        onReconnect = { (c: @escaping (Bool) -> Void) in self.reconnectCallback = c }
        currentLimit = CurrentValueSubject<Int, Never>(0)
        currentAction = CurrentValueSubject<LowRateAction, Never>(.ignore)
        
        controller = AlertingController(
            currentRate: currentRate.eraseToAnyPublisher(),
            toReconnect: onReconnect,
            withLimit: currentLimit.eraseToAnyPublisher(),
            andAction: currentAction.eraseToAnyPublisher()
        )
    }
    
    func testIgnoreActionDoesNotChangeAnything() {
        currentLimit.send(10)
        currentAction.send(.ignore)
        
        XCTAssertEqual(controller.currentState, AlertState.clear)
        
        currentRate.send(1)
        XCTAssertEqual(controller.currentState, AlertState.clear)
        currentRate.send(1)
        XCTAssertEqual(controller.currentState, AlertState.clear)
        currentRate.send(1)
        XCTAssertEqual(controller.currentState, AlertState.clear)
        currentRate.send(1)
        XCTAssertEqual(controller.currentState, AlertState.clear)
        
        XCTAssertNil(reconnectCallback)
    }
    
    func testNotifyActionLogic() {
        currentLimit.send(10)
        currentAction.send(.notify)
        
        XCTAssertEqual(controller.currentState, AlertState.clear)
        
        // trigger after 2 times violated
        currentRate.send(5)
        XCTAssertEqual(controller.currentState, AlertState.clear)
        currentRate.send(5)
        XCTAssertEqual(controller.currentState, AlertState.alert)
    }
    
}
