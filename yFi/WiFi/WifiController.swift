//
//  WiFiManager.swift
//  yFi
//
//  Created by Michael Rose on 09.05.20.
//  Copyright © 2020-2023 Coderose. All rights reserved.
//

import CoreWLAN
import Combine

class WifiController {
    
    let rate$: AnyPublisher<Double, Never>
    
    private let client: CWWiFiClient!
    private let iface: CWInterface!
    
    private var reconnecting = false
    
    init() {
        client = CWWiFiClient.shared()
        
        guard let iface = client.interface() else {
            fatalError("Could not find any wifi interface")
        }
        self.iface = iface
        
        rate$ = Timer.TimerPublisher(interval: 2, runLoop: .main, mode: .default)
            .autoconnect()
            .map({ (_: Date) in iface.transmitRate() })
            .share()
            .eraseToAnyPublisher()
    }
    
    func triggerReconnect(whenReconnected: @escaping (Bool) -> Void) {
        if (reconnecting) {
            return
        }
        reconnecting = true
     
        do {
            try iface.setPower(false)
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
                do {
                    try self?.iface.setPower(true)
                    self?.reconnecting = false
                    whenReconnected(true)
                } catch {
                    print("Failed", error)
                    self?.reconnecting = false
                    whenReconnected(false)
                }
            }
        } catch {
            print("Failed", error)
            reconnecting = false
            whenReconnected(false)
        }
    }
}
