//
//  StatusItemController.swift
//  yFi
//
//  Created by Michael Rose on 14.05.20.
//  Copyright © 2020 Coderose. All rights reserved.
//

import Cocoa
import Foundation
import SwiftUI

class StatusItemController {
    
    private let statusItem = NSStatusBar.system.statusItem(withLength: 70)
    private let settingsPopover = NSPopover()
    private let alertPopover = NSPopover()
    
    private let settings: SettingsModel!
    
    private var showTxRate = true
    private var txRate = 0.0
    
    init(_ settings: SettingsModel) {
        self.settings = settings
        
        if let button = statusItem.button {
            initStatusButton(button)
        }
        
        initSettingsPopover()
        initAlertPopover()
    }
    
    func updateShowTxRate(_ showTxRate: Bool) {
        self.showTxRate = showTxRate
        updateDisplay()
    }
    
    func updateTxRate(_ txRate: Double) {
        self.txRate = txRate
        updateDisplay()
    }
    
    func setAlert(_ alert: Bool) {
        if (settingsPopover.isShown) {
            return
        }
        
        if (alert && !alertPopover.isShown) {
            if let button = self.statusItem.button {
                alertPopover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        } else if (!alert && alertPopover.isShown) {
            alertPopover.close()
        }
    }
    
    private func updateDisplay() {
        if showTxRate {
            let content = String(format: "%.0f", txRate)
            
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
    
    @objc func showSettings(_ sender: Any) {
        if let button = self.statusItem.button {
            settingsPopover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            settingsPopover.contentViewController?.view.window?.becomeKey()
        }
    }
    
    private func initStatusButton(_ button: NSStatusBarButton) {
        let icon = NSImage(imageLiteralResourceName: "menu-icon")
        button.title = "yFi"
        button.image = icon
        button.imagePosition = .imageLeft
        button.target = self
        button.action = #selector(showSettings)
    }
    
    private func initSettingsPopover() {
        let settingsView = SettingsView(model: settings)
        settingsPopover.behavior = .transient
        settingsPopover.contentSize = NSSize(width: 300, height: 100)
        settingsPopover.contentViewController = NSHostingController(rootView: settingsView)
    }
    
    private func initAlertPopover() {
        let alertView = AlertView()
        alertPopover.behavior = .transient
        alertPopover.contentSize = NSSize(width: 120, height: 30)
        alertPopover.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        alertPopover.contentViewController = NSHostingController(rootView: alertView)
    }
}
