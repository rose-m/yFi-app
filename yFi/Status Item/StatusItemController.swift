//
//  StatusItemController.swift
//  yFi
//
//  Created by Michael Rose on 14.05.20.
//  Copyright © 2020-2023 Coderose. All rights reserved.
//

import Cocoa
import Foundation
import Combine
import SwiftUI

class StatusItemController {
    
    private let statusItem = NSStatusBar.system.statusItem(withLength: 50)
    
    private let settingsPopover = NSPopover()
    private var settingsView: SettingsView!
    
    private let alertPopover = NSPopover()
    private let alertViewModel = AlertViewModel()
    private var alertView: AlertView!
    
    private let settings: SettingsModel!
    
    private var itemStyle = StatusBarItemStyle.iconAndTxRate
    private var txRate = 0.0
    
    private var cancelSubscriptions: AnyCancellable?
    
    init(settings: SettingsModel,
         withRate currentRate$: AnyPublisher<Double, Never>,
         currentState state$: AnyPublisher<AlertState, Never>) {
        self.settings = settings
        
        let cancelItemStyle = settings.$itemStyle.sink(receiveValue: onItemStyleChange(_:))
        let cancelRate = currentRate$.sink(receiveValue: onRateChange(_:))
        let cancelState = state$.sink { state in
            DispatchQueue.main.async { self.onStateChange(state) }
        }
        cancelSubscriptions = AnyCancellable({
            cancelItemStyle.cancel()
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
        settingsPopover.contentSize = NSSize(width: SettingsView.WIDTH,
                                             height: SettingsView.HEIGHT)
        settingsPopover.contentViewController = NSHostingController(rootView: settingsView)
    }
    
    private func initAlertPopover() {
        alertView = AlertView(model: alertViewModel)
        alertPopover.behavior = .transient
        alertPopover.contentSize = NSSize(width: AlertView.WIDTH,
                                          height: AlertView.HEIGHT)
        //alertPopover.appearance = NSAppearance(named: NSAppearance.Name.)
        alertPopover.contentViewController = NSHostingController(rootView: alertView)
    }
    
    private func onItemStyleChange(_ itemStyle: StatusBarItemStyle) {
        self.itemStyle = itemStyle
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
            if self.itemStyle == .onlyIcon {
                if let button = self.statusItem.button {
                    self.statusItem.length = NSStatusItem.squareLength
                    button.title = ""
                    button.imagePosition = .imageOnly
                }
                return
            }
            
            let content = self.txRate == 0 ? "N/A" : String(format: "%.0f", self.txRate)
            let itemLength: CGFloat!
            let imagePosition: NSControl.ImagePosition!
            
            if self.itemStyle == .onlyTxRate {
                itemLength = 30
                imagePosition = .noImage
            } else {
                itemLength = 55
                imagePosition = .imageLeft
            }
            
            self.statusItem.length = itemLength
            if let button = self.statusItem.button {
                button.title = content
                button.imagePosition = imagePosition
            }
        }
    }
}
