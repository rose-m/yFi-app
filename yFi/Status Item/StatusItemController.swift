//
//  StatusItemController.swift
//  yFi
//
//  Created by Michael Rose on 14.05.20.
//  Copyright © 2020 Coderose. All rights reserved.
//

import Cocoa
import Foundation
import Combine
import SwiftUI

class StatusItemController {
    
    private static let SETTINGS_VIEW_WIDTH = 300
    private static let SETTINGS_VIEW_HEIGHT = 100
    
    private static let ALERT_VIEW_WIDTH = 180
    private static let ALERT_VIEW_HEIGHT = 30
    
    private let statusItem = NSStatusBar.system.statusItem(withLength: 70)
    
    private let settingsPopover = NSPopover()
    private var settingsView: SettingsView!
    
    private let alertPopover = NSPopover()
    private let alertViewModel = AlertViewModel()
    private var alertView: AlertView!
    
    private let settings: SettingsModel!
    
    private var showTxRate = true
    private var txRate = 0.0
    
    private var cancelSubscriptions: AnyCancellable?
    
    init(settings: SettingsModel,
         withRate currentRate$: AnyPublisher<Double, Never>,
         currentState state$: AnyPublisher<AlertState, Never>) {
        self.settings = settings
        
        let cancelShowTxRate = settings.$showTxRate.sink(receiveValue: onShowTxRateChange)
        let cancelRate = currentRate$.sink(receiveValue: onRateChange)
        let cancelState = state$.sink { state in
            DispatchQueue.main.async { self.onStateChange(state) }
        }
        cancelSubscriptions = AnyCancellable({
            cancelShowTxRate.cancel()
            cancelRate.cancel()
            cancelState.cancel()
        })
        
        if let button = statusItem.button {
            initStatusButton(button)
        }
        
        initSettingsPopover()
        initAlertPopover()
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
        settingsView = SettingsView(model: settings)
        settingsPopover.behavior = .transient
        settingsPopover.contentSize = NSSize(width: StatusItemController.SETTINGS_VIEW_WIDTH,
                                             height: StatusItemController.SETTINGS_VIEW_HEIGHT)
        settingsPopover.contentViewController = NSHostingController(rootView: settingsView)
    }
    
    private func initAlertPopover() {
        alertView = AlertView(model: alertViewModel)
        alertPopover.behavior = .transient
        alertPopover.contentSize = NSSize(width: StatusItemController.ALERT_VIEW_WIDTH,
                                          height: StatusItemController.ALERT_VIEW_HEIGHT)
        alertPopover.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        alertPopover.contentViewController = NSHostingController(rootView: alertView)
    }
    
    private func onShowTxRateChange(_ showTxRate: Bool) {
        self.showTxRate = showTxRate
        updateDisplay()
    }
    
    private func onRateChange(_ txRate: Double) {
        self.txRate = txRate
        updateDisplay()
    }
    
    private func onStateChange(_ state: AlertState) {
        switch state {
        case .alert, .reconnecting, .reconnected, .failed:
            alertViewModel.state = state
            if (!alertPopover.isShown && !settingsPopover.isShown) {
                if let button = self.statusItem.button {
                    alertPopover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                }
            }
        default:
            if (alertPopover.isShown) {
                alertPopover.close()
            }
        }
    }
    
    private func updateDisplay() {
        DispatchQueue.main.async {
            if self.showTxRate {
                let content = String(format: "%.0f", self.txRate)
                
                self.statusItem.length = 70
                if let button = self.statusItem.button {
                    button.title = content
                    button.imagePosition = .imageLeft
                }
            } else if let button = self.statusItem.button {
                self.statusItem.length = NSStatusItem.squareLength
                button.title = ""
                button.imagePosition = .imageOnly
            }
        }
    }
}
