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

enum LowRateAction: String, Codable {
    case notify = "notify"
    case reconnect = "reconnect"
    case ignore = "ignore"
}

class SettingsModel : ObservableObject {
    
    static let DEFAULT_LOW_RATE_ACTION: LowRateAction = .notify
    
    @Published var showTxRate: Bool
    
    @Published var rateLimit: Int
    
    @Published var currentTxRate: Double = 0
    
    @Published var lowRateAction: LowRateAction
    
    @Published var launchAtLogin: Bool = false
    
    var onQuit: (() -> Void)?
    
    init(showTxRate: Bool = true, rateLimit: Int = 0, lowRateAction: LowRateAction = .notify, onQuit: (() -> Void)? = nil) {
        self.showTxRate = showTxRate
        self.rateLimit = rateLimit
        self.lowRateAction = lowRateAction
        self.onQuit = onQuit
    }
    
    init(fromDefaultsWithOnQuit onQuit: (() -> Void)? = nil) {
        showTxRate = Defaults[.showTxRate]
        rateLimit = Defaults[.rateLimit]
        lowRateAction = Defaults[.lowRateAction]
        self.onQuit = onQuit
    }
    
}
