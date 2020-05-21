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
    static let showTxRate = Key<Bool>("showTxRate", default: true)
    static let rateLimit = Key<Int>("rateLimit", default: 0)
    static let lowRateAction = Key<LowRateAction>("lowRateAction", default: .notify)
}
