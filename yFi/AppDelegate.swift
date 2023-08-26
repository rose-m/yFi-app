//
//  AppDelegate.swift
//  yFi
//
//  Created by Michael Rose on 09.05.20.
//  Copyright © 2020-2023 Coderose. All rights reserved.
//

import Cocoa
import SwiftUI
import Combine
import LaunchAtLogin
import Defaults

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var settings: SettingsModel!
    
    var statusItemController: StatusItemController!
    var wifiManager: WifiController!
    var alertingController: AlertingController!
    
    var cancelSubscriptions: AnyCancellable?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // We do not create a window here
        NSApp.setActivationPolicy(.accessory)
        
        settings = SettingsModel(fromDefaultsWithOnQuit: {
            NSApp.terminate(self)
        })
        settings.launchAtLogin = LaunchAtLogin.isEnabled
        let cancelLaunchAtLogin = settings.$launchAtLogin.sink(receiveValue: onLaunchAtLoginChange(_:))
        let cancelDefaultsItemStyle = settings.$itemStyle.sink(receiveValue: { itemStyle in Defaults[.itemStyle] = itemStyle })
        let cancelDefaultsRateLimit = settings.$rateLimit.sink(receiveValue: { limit in Defaults[.rateLimit] = limit })
        let cancelDefaultsLowRateAction = settings.$lowRateAction.sink(receiveValue: { action in Defaults[.lowRateAction] = action })
        
        wifiManager = WifiController()
        let cancelUpdateTxRate = wifiManager.rate$.assign(to: \SettingsModel.currentTxRate, on: settings)
        
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
        
        cancelSubscriptions = AnyCancellable({
            cancelLaunchAtLogin.cancel()
            cancelUpdateTxRate.cancel()
            
            cancelDefaultsItemStyle.cancel()
            cancelDefaultsRateLimit.cancel()
            cancelDefaultsLowRateAction.cancel()
        })
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        if let c = cancelSubscriptions {
            c.cancel()
            cancelSubscriptions = nil
        }
    }
    
    private func onLaunchAtLoginChange(_ launchAtLogin: Bool) {
        if (LaunchAtLogin.isEnabled != launchAtLogin) {
            LaunchAtLogin.isEnabled = launchAtLogin
        }
    }
    
}
