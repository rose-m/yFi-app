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
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // We do not create a window here
        NSApp.setActivationPolicy(.accessory)
        
        wifiManager = WifiController()
        
        alertingController = AlertingController(
            currentRate: wifiManager.rate$,
            toReconnect: wifiManager.triggerReconnect,
            withLimit: settings.$rateLimit.eraseToAnyPublisher(),
            andAction: settings.$lowRateAction.eraseToAnyPublisher()
        )
        
        statusItemController = StatusItemController(
            settings: settings,
            withRate: wifiManager.rate$,
            currentState: alertingController.state$
        )
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
    }
    
}
