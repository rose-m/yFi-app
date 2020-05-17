//
//  AlertingController.swift
//  yFi
//
//  Created by Michael Rose on 16.05.20.
//  Copyright © 2020 Coderose. All rights reserved.
//

import Foundation
import Combine

typealias OnReconnectCallback = (@escaping (Bool) -> Void) -> Void

class AlertingController : ObservableObject {
    
    let state$: AnyPublisher<AlertState, Never>
    var currentState: AlertState {
        get {
            _state$.value
        }
    }
    
    private let _state$ = CurrentValueSubject<AlertState, Never>(.clear)
    
    private var lowRateAction: LowRateAction = .notify
    private var rateLimit: Int = 0
    private var violationCounter = 0
    private var ticksInState = 0
    
    private let onReconnect: OnReconnectCallback;
    
    private var cancelSubscriptions: AnyCancellable?
        
    init(currentRate rate$: AnyPublisher<Double, Never>,
         toReconnect onReconnect: @escaping OnReconnectCallback,
         withLimit limit$: AnyPublisher<Int, Never>,
         andAction action$: AnyPublisher<LowRateAction, Never>) {
        state$ = _state$.share().eraseToAnyPublisher()
        
        self.onReconnect = onReconnect
        
        let cancelRate = rate$.sink(receiveValue: onTickRate(_:))
        let cancelLimit = limit$.sink(receiveValue: onLimitChange(_:))
        let cancelAction = action$.sink(receiveValue: onLowRateActionChange(_:))
        cancelSubscriptions = AnyCancellable({
            cancelRate.cancel()
            cancelLimit.cancel()
            cancelAction.cancel()
        })
    }
    
    func shutdown() -> Void {
        if let c = cancelSubscriptions {
            c.cancel()
            cancelSubscriptions = nil
        }
    }
    
    private func onTickRate(_ txRate: Double) -> Void {
        let currentState = _state$.value
        var state: AlertState?
        
        if (lowRateAction == .ignore) {
            violationCounter = 0
            ticksInState = 0
            state = .clear
        } else if (txRate == 0) {
            if (currentState == .reconnecting || currentState == .reconnected) {
                violationCounter = 0
            }
            state = currentState
        } else {
            let violated = txRate < Double(rateLimit)
            
            switch currentState {
            case .clear:
                violationCounter = violated ? violationCounter + 1 : 0
                if (violationCounter >= 2) {
                    violationCounter = 0
                    state = .alert
                } else {
                    state = .clear
                }
            case .alert:
                violationCounter = violated ? 0 : violationCounter + 1
                if (violationCounter >= 2) {
                    violationCounter = 0
                    state = .clear
                } else if (lowRateAction == .notify) {
                    state = .alert
                } else if (ticksInState == 1) {
                    violationCounter = 0
                    state = .reconnecting
                } else {
                    state = .alert
                }
            case .reconnecting:
                onReconnect({ (success) in
                    self.violationCounter = 0
                    self._state$.send(success ? .reconnected : .failed)
                })
                state = .reconnecting
            case .reconnected:
                if (violated) {
                    state = .failed
                } else {
                    violationCounter += 1
                    if (violationCounter >= 2) {
                        state = .clear
                    } else {
                        state = .reconnected
                    }
                }
            case .failed:
                violationCounter = violated ? 0 : violationCounter + 1
                if (violationCounter >= 2) {
                    violationCounter = 0
                    state = .clear
                } else {
                    state = .failed
                }
            }
        }
        
        if let s = state {
            if (s == currentState) {
                ticksInState += 1
            } else {
                ticksInState = 0
            }
            self._state$.send(s)
        } else {
            print("ERROR: new state was not set")
        }
    }
    
    private func onLimitChange(_ limit: Int) -> Void {
        rateLimit = limit
        violationCounter = 0
        ticksInState = 0
        _state$.send(.clear)
    }
    
    private func onLowRateActionChange(_ action: LowRateAction) -> Void {
        lowRateAction = action
        if (lowRateAction == .ignore) {
            _state$.send(.clear)
            violationCounter = 0
        }
    }
}
