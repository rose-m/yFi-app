//
//  AlertingController.swift
//  yFi
//
//  Created by Michael Rose on 14.05.20.
//  Copyright © 2020 Coderose. All rights reserved.
//

import Foundation

enum AlertLevel {
    case clear
    case alert
}

class AlertingControllerOld {
    
    private static let NUM_VIOLATIONS = 2
    private static let NUM_ABOVE_TO_CLEAR = 3
    
    private let trigger: (AlertLevel) -> Void
    private var limit: Int?
    private var value: Double?
    
    private var level = AlertLevel.clear
    private var levelCount = 0
    
    init(_ trigger: @escaping (AlertLevel) -> Void) {
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
                limitViolated(reactImmediately)
            } else {
                limitSatisfied(reactImmediately)
            }
        }
    }
    
    private func limitViolated(_ reactImmediately: Bool) {
        if (level == .alert) {
            levelCount = 0
        } else {
            if (levelCount < AlertingController.NUM_VIOLATIONS) {
                levelCount += 1
            }
            
            if (levelCount == AlertingController.NUM_VIOLATIONS) {
                level = .alert
                levelCount = 0
            }
        }
        
        trigger(level)
    }
    
    private func limitSatisfied(_ reactImmediately: Bool) {
        if (reactImmediately) {
            level = .clear
            levelCount = 0
        } else if (level == .clear) {
            levelCount = 0
        } else {
            if (levelCount < AlertingController.NUM_ABOVE_TO_CLEAR) {
                levelCount += 1
            }
            
            if (levelCount == AlertingController.NUM_ABOVE_TO_CLEAR) {
                level = .clear
                trigger(level)
                levelCount = 0
            }
        }
        
        trigger(level)
    }
}
