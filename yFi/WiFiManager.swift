//
//  WiFiManager.swift
//  yFi
//
//  Created by Michael Rose on 09.05.20.
//  Copyright © 2020 Coderose. All rights reserved.
//

import CoreWLAN

class WiFiManager {
    
    private let client: CWWiFiClient!
    private let iface: CWInterface!
    
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
    
}
