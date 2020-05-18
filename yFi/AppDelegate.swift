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
import LaunchAtLogin

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var settings: SettingsModel!
    
    var statusItemController: StatusItemController!
    var wifiManager: WifiController!
    var alertingController: AlertingController!
    
    var launchAtLoginCancellable: AnyCancellable?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // We do not create a window here
        NSApp.setActivationPolicy(.accessory)
        
        settings = SettingsModel(onQuit: {
            NSApp.terminate(self)
        })
        settings.launchAtLogin = LaunchAtLogin.isEnabled
        launchAtLoginCancellable = settings.$launchAtLogin.sink(receiveValue: onLaunchAtLoginChange(_:))
        
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
        if let c = launchAtLoginCancellable {
            c.cancel()
            launchAtLoginCancellable = nil
        }
    }
    
    private func onLaunchAtLoginChange(_ launchAtLogin: Bool) {
        if (LaunchAtLogin.isEnabled != launchAtLogin) {
            LaunchAtLogin.isEnabled = launchAtLogin
        }
    }
    
}
