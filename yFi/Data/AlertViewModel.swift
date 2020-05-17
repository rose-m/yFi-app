//
//  AlertViewModel.swift
//  yFi
//
//  Created by Michael Rose on 17.05.20.
//  Copyright © 2020 Coderose. All rights reserved.
//

import Foundation
import SwiftUI

class AlertViewModel : ObservableObject {
    
    @Published var state: AlertState = .clear
    
    var icon: String {
        get {
            switch state {
            case .clear:
                return "icon-check"
            case .reconnecting:
                return "icon-reconnect"
            case .reconnected:
                return "icon-check"
            case .failed:
                return "icon-failed"
            default:
                return "icon-warning"
            }
        }
    }
    
    var color: Color {
        get {
            switch state {
            case .clear:
                return .green
            case .reconnecting:
                return .yellow
            case .reconnected:
                return .green
            case .failed:
                return .red
            default:
                return Color.yellow
            }
        }
    }
    
    var content: LocalizedStringKey {
        get {
            switch state {
            case .clear:
                return LocalizedStringKey(stringLiteral: "WiFi working normally")
            case .reconnecting:
                return LocalizedStringKey(stringLiteral: "Reconnecting...")
            case .reconnected:
                return LocalizedStringKey(stringLiteral: "Reconnected")
            case .failed:
                return LocalizedStringKey(stringLiteral: "WiFi issues persist")
            default:
                return LocalizedStringKey(stringLiteral: "WiFi rate dropped")
            }
        }
    }
    
}
