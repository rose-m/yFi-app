//
//  AlertingController.swift
//  yFi
//
//  Created by Michael Rose on 16.05.20.
//  Copyright © 2020 Coderose. All rights reserved.
//

import Foundation
import Combine

class AlertingController : ObservableObject {
    
    enum State {
        case clear
        case alert
        case reconnecting
        case reconnected
        case failed
    }
    
    let state$: AnyPublisher<State, Never>
    
    private let _state$ = CurrentValueSubject<State, Never>(.clear)
    private let wifi: WifiController
    
    private var tickTimer$: Timer.TimerPublisher!
    private var limitViolatedCancellable: AnyCancellable!
    private var violationCounter = 0
    
    private var lowRateAction: LowRateAction = .notify
    private var rateLimit: Int = 0
    private var settingsCancellable: AnyCancellable?
    
    init(_ wifiController: WifiController, _ settings: SettingsModel) {
        state$ = _state$.eraseToAnyPublisher()
        
        wifi = wifiController
        
        tickTimer$ = initTimer()
        limitViolatedCancellable = tickTimer$
            .map { (date: Date) in self.wifi.currentTxRate() }
            .filter { r in r != 0}
            .map { r in r < Double(self.rateLimit) }
            .sink { v in self.onViolation(v) }
        
        settingsCancellable = initSettings(settings)
    }
    
    private func onViolation(_ violated: Bool) -> Void {
        var state: State?
        if (lowRateAction == .ignore) {
            violationCounter = 0
            state = .clear
        } else {
            switch self._state$.value {
            case .clear:
                violationCounter = violated ? violationCounter + 1 : 0
                if (violationCounter >= 2) {
                    violationCounter = 0
                    state = lowRateAction == .notify ? .alert : .reconnecting
                } else {
                    state = .clear
                }
            case .alert:
                violationCounter = violated ? 0 : violationCounter + 1
                if (violationCounter >= 2) {
                    violationCounter = 0
                    state = .clear
                } else {
                    state = .alert
                }
            case .reconnecting:
                state = .reconnecting
                wifi.triggerReconnect() {
                    self.violationCounter = 0
                    self._state$.send(.reconnected)
                }
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
            self._state$.send(s)
        } else {
            print("ERROR: new state was not set")
        }
    }
    
    private func initTimer() -> Timer.TimerPublisher {
        return Timer.TimerPublisher(interval: 2, runLoop: .main, mode: .default)
    }
    
    private func initSettings(_ settings: SettingsModel) -> AnyCancellable {
        let lowRateCancellable = settings.$lowRateAction.sink { (action) in
            self.lowRateAction = action
        }
        let rateLimitCancellable = settings.$rateLimit.sink { (limit) in
            self.rateLimit = limit
        }
        return AnyCancellable {
            lowRateCancellable.cancel()
            rateLimitCancellable.cancel()
        }
    }
}
