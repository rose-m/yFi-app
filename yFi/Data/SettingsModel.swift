//
//  SettingsModel.swift
//  yFi
//
//  Created by Michael Rose on 10.05.20.
//  Copyright © 2020 Coderose. All rights reserved.
//

import Foundation
import Combine

enum LowRateAction {
    case notify
    case reconnect
    case ignore
}

class SettingsModel : ObservableObject {
    
    static let DEFAULT_LOW_RATE_ACTION: LowRateAction = .notify
    
    @Published var showTxRate: Bool = true
    
    @Published var rateLimit: Int = 30
    
    @Published var lowRateAction: LowRateAction = SettingsModel.DEFAULT_LOW_RATE_ACTION
    
    var onQuit: (() -> Void)?
    
    init(onQuit: (() -> Void)? = nil) {
        self.onQuit = onQuit
    }
    
}
