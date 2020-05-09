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
    
    init() {
        client = CWWiFiClient.shared()
    }
    
    func currentTxRate() {
        if let interfaces = client.interfaces() {
            for interface in interfaces {
                print(interface)
            }
        }
    }
    
}
