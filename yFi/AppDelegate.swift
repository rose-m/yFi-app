//
//  AppDelegate.swift
//  yFi
//
//  Created by Michael Rose on 09.05.20.
//  Copyright © 2020 Coderose. All rights reserved.
//

import Cocoa
import SwiftUI
import Combine

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let settings = SettingsModel()
    
    var statusItemController: StatusItemController!
    var wifiManager: WifiController!
    var alertingController: AlertingController!
    
    var cancelShowTxRate: AnyCancellable?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // We do not create a window here
        NSApp.setActivationPolicy(.accessory)
        
        statusItemController = StatusItemController(settings)
        wifiManager = WifiController()
        
        alertingController = AlertingController(wifiManager, settings)
                
        cancelShowTxRate = settings.$showTxRate.sink { [weak self] showTxRate in
            DispatchQueue.main.async {
                self?.statusItemController.updateShowTxRate(showTxRate)
            }
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        if let c = cancelShowTxRate {
            c.cancel()
            cancelShowTxRate = nil
        }
    }
}
