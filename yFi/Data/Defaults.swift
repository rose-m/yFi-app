//
//  Defaults.swift
//  yFi
//
//  Created by Michael Rose on 21.05.20.
//  Copyright © 2020 Coderose. All rights reserved.
//

import Foundation
import Defaults

extension Defaults.Keys {
    
    @available(*, deprecated, message: "This flag is not supported anymore and should be migrated to itemStyle")
    static let showTxRate = Key<Bool?>("showTxRate", default: nil)
    
    static let itemStyle = Key<StatusBarItemStyle?>("itemStyle", default: nil)
    static let rateLimit = Key<Int>("rateLimit", default: 0)
    static let lowRateAction = Key<LowRateAction>("lowRateAction", default: .notify)
    
}
