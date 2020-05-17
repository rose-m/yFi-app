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
        
        // twice OK resets state
        currentRate.send(40)
        XCTAssertEqual(controller.currentState, AlertState.alert)
        currentRate.send(40)
        XCTAssertEqual(controller.currentState, AlertState.clear)
        
        // bouncing state does not change behavior
        currentRate.send(5)
        XCTAssertEqual(controller.currentState, AlertState.clear)
        currentRate.send(5)
        XCTAssertEqual(controller.currentState, AlertState.alert)
        currentRate.send(40)
        XCTAssertEqual(controller.currentState, AlertState.alert)
        currentRate.send(5)
        XCTAssertEqual(controller.currentState, AlertState.alert)
        currentRate.send(40)
        XCTAssertEqual(controller.currentState, AlertState.alert)
        currentRate.send(5)
        XCTAssertEqual(controller.currentState, AlertState.alert)
        
        // Disabled i.e. 0 does not change state
        currentRate.send(0)
        XCTAssertEqual(controller.currentState, AlertState.alert)
        currentRate.send(0)
        XCTAssertEqual(controller.currentState, AlertState.alert)
        currentRate.send(0)
        XCTAssertEqual(controller.currentState, AlertState.alert)
        
        // changing action to ignore immediately changes state
        currentAction.send(.ignore)
        XCTAssertEqual(controller.currentState, AlertState.clear)
        
        XCTAssertNil(reconnectCallback)
    }
    
    func testReconnectSuccessButLowRateActionLogic() {
        currentLimit.send(10)
        currentAction.send(.reconnect)
        
        XCTAssertEqual(controller.currentState, AlertState.clear)
        
        // switching to alert state
        currentRate.send(1)
        currentRate.send(1)
        XCTAssertEqual(controller.currentState, AlertState.alert)
        
        // two more failures trigger reconnect
        currentRate.send(1)
        XCTAssertEqual(controller.currentState, AlertState.alert)
        currentRate.send(1)
        XCTAssertEqual(controller.currentState, AlertState.reconnecting)
        XCTAssertNil(reconnectCallback)
        // tick required for reconnect
        currentRate.send(1)
        XCTAssertEqual(controller.currentState, AlertState.reconnecting)
        XCTAssertNotNil(reconnectCallback)
        
        // improved rate now does not change
        currentRate.send(100)
        XCTAssertEqual(controller.currentState, AlertState.reconnecting)
        
        reconnectCallback!(true)
        XCTAssertEqual(controller.currentState, AlertState.reconnected)
        
        currentRate.send(5)
        XCTAssertEqual(controller.currentState, AlertState.failed)
        
        // further low rates don't change
        currentRate.send(5)
        XCTAssertEqual(controller.currentState, AlertState.failed)
        currentRate.send(5)
        XCTAssertEqual(controller.currentState, AlertState.failed)
        currentRate.send(5)
        XCTAssertEqual(controller.currentState, AlertState.failed)
    }
    
    func testReconnectSuccessWithHighRateLogic() {
        currentLimit.send(10)
        currentAction.send(.reconnect)
        
        XCTAssertEqual(controller.currentState, AlertState.clear)
        
        // switching to alert state
        currentRate.send(1)
        currentRate.send(1)
        XCTAssertEqual(controller.currentState, AlertState.alert)
        
        // two more failures trigger reconnect
        currentRate.send(1)
        XCTAssertEqual(controller.currentState, AlertState.alert)
        currentRate.send(1)
        XCTAssertEqual(controller.currentState, AlertState.reconnecting)
        XCTAssertNil(reconnectCallback)
        // tick required for reconnect
        currentRate.send(1)
        XCTAssertEqual(controller.currentState, AlertState.reconnecting)
        XCTAssertNotNil(reconnectCallback)
        
        // improved rate now does not change
        currentRate.send(100)
        XCTAssertEqual(controller.currentState, AlertState.reconnecting)
        
        reconnectCallback!(true)
        XCTAssertEqual(controller.currentState, AlertState.reconnected)
        
        // Requires two successful high rates
        currentRate.send(100)
        XCTAssertEqual(controller.currentState, AlertState.reconnected)
        currentRate.send(100)
        XCTAssertEqual(controller.currentState, AlertState.clear)
    }
    
    func testReconnectFailsActionLogic() {
        currentLimit.send(10)
        currentAction.send(.reconnect)
        
        XCTAssertEqual(controller.currentState, AlertState.clear)
        
        // switching to alert state
        currentRate.send(1)
        currentRate.send(1)
        XCTAssertEqual(controller.currentState, AlertState.alert)
        
        currentRate.send(1)
        currentRate.send(1)
        currentRate.send(1)
        XCTAssertEqual(controller.currentState, AlertState.reconnecting)
        XCTAssertNotNil(reconnectCallback)
        
        reconnectCallback!(false)
        XCTAssertEqual(controller.currentState, AlertState.failed)
        
        // Requires two successful high rates
        currentRate.send(100)
        XCTAssertEqual(controller.currentState, AlertState.failed)
        currentRate.send(100)
        XCTAssertEqual(controller.currentState, AlertState.clear)
    }
    
    func testNoLimitDoesNotCauseAction() {
        currentLimit.send(0)
        currentAction.send(.notify)
        
        XCTAssertEqual(controller.currentState, AlertState.clear)
        
        currentRate.send(1)
        XCTAssertEqual(controller.currentState, AlertState.clear)
        currentRate.send(20)
        XCTAssertEqual(controller.currentState, AlertState.clear)
        currentRate.send(0)
        XCTAssertEqual(controller.currentState, AlertState.clear)
        
        currentLimit.send(10)
        XCTAssertEqual(controller.currentState, AlertState.clear)
        currentRate.send(1)
        currentRate.send(1)
        XCTAssertEqual(controller.currentState, AlertState.alert)
        
        currentLimit.send(0)
        XCTAssertEqual(controller.currentState, AlertState.clear)
    }
}
