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
    
    var updateTxRateTimer: Timer?
    
    var cancelShowTxRate: AnyCancellable?
    var cancelRateLimit: AnyCancellable?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // We do not create a window here
        NSApp.setActivationPolicy(.accessory)
        
        statusItemController = StatusItemController(settings)
        wifiManager = WifiController()
        alertingController = AlertingController({ [weak self] alert in
            self?.statusItemController.setAlert(alert == .alert)
        })
        alertingController.updateLimit(settings.rateLimit)
        
        updateTxRateTimer = scheduleUpdateTxRateTimer()
        
        cancelShowTxRate = settings.$showTxRate.sink { [weak self] showTxRate in
            DispatchQueue.main.async {
                self?.statusItemController.updateShowTxRate(showTxRate)
            }
        }
        cancelRateLimit = settings.$rateLimit.sink { [weak self] rateLimit in
            self?.alertingController.updateLimit(rateLimit)
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        if let t = updateTxRateTimer {
            t.invalidate()
            updateTxRateTimer = nil
        }
        if let c = cancelShowTxRate {
            c.cancel()
        }
        if let c = cancelRateLimit {
            c.cancel()
        }
    }
    
    private func scheduleUpdateTxRateTimer() -> Timer {
        return Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { [weak self] (t) in
            if let s = self {
                let rate = s.wifiManager.currentTxRate()
                s.alertingController.updateValue(rate)
                s.statusItemController.updateTxRate(rate)
            }
        })
    }
}
