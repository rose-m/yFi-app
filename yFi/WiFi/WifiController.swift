//
//  WiFiManager.swift
//  yFi
//
//  Created by Michael Rose on 09.05.20.
//  Copyright © 2020 Coderose. All rights reserved.
//

import CoreWLAN

class WifiController {
    
    private let client: CWWiFiClient!
    private let iface: CWInterface!
    
    private var reconnecting = false
    private var reconnectTimer: Timer?
    
    init() {
        client = CWWiFiClient.shared()
        
        guard let iface = client.interface() else {
            fatalError("Could not find any wifi interface")
        }
        self.iface = iface
    }
    
    func currentTxRate() -> Double {
        return iface.transmitRate()
    }
    
    func triggerReconnect() {
        if (currentTxRate() == 0 || reconnectTimer != nil) {
            return
        }
        
        reconnectTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: self.reconnect)
    }
    
    func cancelReconnect() {
        if let timer = reconnectTimer {
            timer.invalidate()
        }
        reconnectTimer = nil
    }
    
    private func reconnect(_ timer: Timer) {
        print("Reconnecting...")
    }
}
