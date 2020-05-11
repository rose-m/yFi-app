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
    
    let statusItem = NSStatusBar.system.statusItem(withLength: 70)
    let settings = SettingsModel()
    
    var wifiManager: WifiController!
    var popover: NSPopover!
    var updateTxRateTimer: Timer?
    var cancelShowTxRate: AnyCancellable?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // We do not create a window here
        NSApp.setActivationPolicy(.accessory)
        
        wifiManager = WifiController()
        initStatusItem()
        popover = createPopover()
        updateTxRateTimer = scheduleUpdateTxRateTimer()
        
        cancelShowTxRate = settings.$showTxRate.sink { [weak self] showTxRate in
            DispatchQueue.main.async {
                self?.updateStatusItem(showTxRate)
            }
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        if let t = updateTxRateTimer {
            t.invalidate()
            updateTxRateTimer = nil
        }
        if let c = cancelShowTxRate {
            c.cancel()
        }
    }
    
    @objc func showSettings(_ sender: Any) {
        if let button = self.statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.becomeKey()
        }
    }
    
    private func initStatusItem() {
        if let button = statusItem.button {
            let icon = NSImage(imageLiteralResourceName: "menu-icon")
            button.title = "yFi"
            button.image = icon
            button.imagePosition = .imageLeft
            button.target = self
            button.action = #selector(showSettings)
        }
    }
    
    private func createPopover() -> NSPopover {
        let settingsView = SettingsView(model: settings)
        let popover = NSPopover()
        popover.behavior = .transient
        popover.contentSize = NSSize(width: 300, height: 100)
        popover.contentViewController = NSHostingController(rootView: settingsView)
        return popover
    }
    
    private func scheduleUpdateTxRateTimer() -> Timer {
        return Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { [weak self] (t) in
            if let s = self {
                s.updateStatusItem(s.settings.showTxRate)
            }
        })
    }
    
    private func updateStatusItem(_ showTxRate: Bool) {
        if showTxRate {
            let rate = wifiManager.currentTxRate()
            let content = String(format: "%.0f", rate)
            
            statusItem.length = 70
            if let button = statusItem.button {
                button.title = content
                button.imagePosition = .imageLeft
            }
        } else if let button = statusItem.button {
            statusItem.length = NSStatusItem.squareLength
            button.title = ""
            button.imagePosition = .imageOnly
        }
    }
}
