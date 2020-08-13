//
//  SettingsModel.swift
//  yFi
//
//  Created by Michael Rose on 10.05.20.
//  Copyright © 2020 Coderose. All rights reserved.
//

import Foundation
import Combine
import Defaults

enum StatusBarItemStyle: String, Codable {
    case onlyIcon = "onlyIcon"
    case onlyTxRate = "onlyTxRate"
    case iconAndTxRate = "iconAndTxRate"
}

enum LowRateAction: String, Codable {
    case notify = "notify"
    case reconnect = "reconnect"
    case ignore = "ignore"
}

class SettingsModel : ObservableObject {
    
    static let DEFAULT_LOW_RATE_ACTION: LowRateAction = .notify
    
    @Published var itemStyle: StatusBarItemStyle
    
    @Published var rateLimit: Int
    
    @Published var currentTxRate: Double = 0
    
    @Published var lowRateAction: LowRateAction
    
    @Published var launchAtLogin: Bool = false
    
    var onQuit: (() -> Void)?
    
    init(itemStyle: StatusBarItemStyle = .iconAndTxRate,
         rateLimit: Int = 0,
         lowRateAction: LowRateAction = .notify,
         onQuit: (() -> Void)? = nil) {
        self.itemStyle = itemStyle
        self.rateLimit = rateLimit
        self.lowRateAction = lowRateAction
        self.onQuit = onQuit
    }
    
    init(fromDefaultsWithOnQuit onQuit: (() -> Void)? = nil) {
        let showTxRate = Defaults[.showTxRate]
        let defaultsItemStyle = Defaults[.itemStyle]
        
        if let itemStyle = defaultsItemStyle {
            self.itemStyle = itemStyle
        } else {
            if let showRate = showTxRate {
                itemStyle = showRate ? .iconAndTxRate : .onlyIcon
            } else {
                itemStyle = .iconAndTxRate
            }
        }
        
        rateLimit = Defaults[.rateLimit]
        lowRateAction = Defaults[.lowRateAction]
        self.onQuit = onQuit
    }
    
}
