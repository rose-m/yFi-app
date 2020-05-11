//
//  SettingsModel.swift
//  yFi
//
//  Created by Michael Rose on 10.05.20.
//  Copyright © 2020 Coderose. All rights reserved.
//

import Foundation
import Combine

class SettingsModel : ObservableObject {
    
    @Published var showTxRate: Bool = true
    
    @Published var rateLimit: Int = 0
    
}
