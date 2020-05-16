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
    
    private var lowRateAction: LowRateAction = .notify
    private var rateLimit: Int = 0
    
    private var violationCounter = 0
    
    private var tickCancellable: AnyCancellable?
    private var settingsCancellable: AnyCancellable?
    
    init(_ wifiController: WifiController, _ settings: SettingsModel) {
        state$ = _state$.eraseToAnyPublisher()
        
        wifi = wifiController
        
        tickCancellable = wifi.rate$.sink(receiveValue: onTickRate)
        
        settingsCancellable = initSettings(settings)
    }
    
    func shutdown() -> Void {
        if let c = tickCancellable {
            c.cancel()
            tickCancellable = nil
        }
        if let c = settingsCancellable {
            c.cancel()
            settingsCancellable = nil
        }
    }
    
    private func onTickRate(_ txRate: Double) -> Void {
        var state: State?
        
        if (lowRateAction == .ignore || txRate == 0) {
            violationCounter = 0
            state = .clear
        } else {
            let violated = txRate < Double(rateLimit)
            
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
                } else if (lowRateAction == .reconnect) {
                    violationCounter = 0
                    state = .reconnecting
                } else {
                    state = .alert
                }
            case .reconnecting:
                violationCounter += 1
                if (violationCounter == 2) {
                    wifi.triggerReconnect(do: { (success) in
                        self.violationCounter = 0
                        self._state$.send(success ? .reconnected : .failed)
                    })
                }
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
            self._state$.send(s)
        } else {
            print("ERROR: new state was not set")
        }
    }
    
    private func initSettings(_ settings: SettingsModel) -> AnyCancellable {
        let lowRateCancellable = settings.$lowRateAction.sink { (action) in
            self.lowRateAction = action
            if (self.lowRateAction == .ignore) {
                self._state$.send(.clear)
                self.violationCounter = 0
            }
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
