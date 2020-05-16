//
//  AlertingView.swift
//  yFi
//
//  Created by Michael Rose on 14.05.20.
//  Copyright © 2020 Coderose. All rights reserved.
//

import SwiftUI
import Foundation
import Combine

class AlertViewModel : ObservableObject {
    
    @Published var state: AlertState = .clear
    
}

struct AlertView : View {
    
    @ObservedObject var model: AlertViewModel
    
    private var icon: String {
        get {
            switch model.state {
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
    private var color: Color {
        get {
            switch model.state {
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
    
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Image(icon)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(color)
                    .frame(width: 15, height: 15)
                Text("Bad WiFi quality...")
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
}

struct AlertView_Previews: PreviewProvider {
    static var previews: some View {
        AlertView(model: AlertViewModel()).frame(width: 150, height: 30)
    }
}

