//
//  AlertViewModel.swift
//  yFi
//
//  Created by Michael Rose on 17.05.20.
//  Copyright © 2020-2023 Coderose. All rights reserved.
//

import Foundation
import SwiftUI

class AlertViewModel : ObservableObject {
    
    public static let GREEN_COLOR = Color(red: 127.0 / 255.0, green: 212.0 / 255.0, blue: 0)
    public static let YELLOW_COLOR = Color(red: 247.0 / 255.0, green: 203.0 / 255.0, blue: 21.0 / 255.0)
    public static let RED_COLOR = Color(red: 245.0 / 255.0, green: 93.0 / 255.0, blue: 62.0 / 255.0)
    
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
                return AlertViewModel.GREEN_COLOR
            case .reconnecting:
                return AlertViewModel.YELLOW_COLOR
            case .reconnected:
                return AlertViewModel.GREEN_COLOR
            case .failed:
                return AlertViewModel.RED_COLOR
            default:
                return AlertViewModel.YELLOW_COLOR
            }
        }
    }
    
    var content: LocalizedStringKey {
        get {
            switch state {
            case .clear:
                return LocalizedStringKey("alertView.label.clear")
            case .reconnecting:
                return LocalizedStringKey("alertView.label.reconnecting")
            case .reconnected:
                return LocalizedStringKey("alertView.label.reconnected")
            case .failed:
                return LocalizedStringKey("alertView.label.failed")
            default:
                return LocalizedStringKey("alertView.label.issues")
            }
        }
    }
    
}
