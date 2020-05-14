//
//  AlertingController.swift
//  yFi
//
//  Created by Michael Rose on 14.05.20.
//  Copyright © 2020 Coderose. All rights reserved.
//

import Foundation

class AlertingController {
    
    private let trigger: (Bool) -> Void
    private var limit: Int?
    private var value: Double?
    
    init(_ trigger: @escaping (Bool) -> Void) {
        self.trigger = trigger
    }
    
    func updateLimit(_ limit: Int) {
        self.limit = limit
        checkLimit(true)
    }
    
    func updateValue(_ value: Double) {
        self.value = value
        checkLimit(false)
    }
    
    private func checkLimit(_ reactImmediately: Bool) {
        if let limit = self.limit, let value = self.value {
            if (value > 0 && value < Double(limit)) {
                self.trigger(true)
            } else {
                self.trigger(false)
            }
        }
    }
    
}
