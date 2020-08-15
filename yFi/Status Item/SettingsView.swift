//
//  SettingsView.swift
//  yFi
//
//  Created by Michael Rose on 09.05.20.
//  Copyright © 2020 Coderose. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    
    public static let WIDTH: CGFloat = 300.0
    public static let HEIGHT: CGFloat = 245.0
    
    @ObservedObject var model: SettingsModel
    
    var currentTxRate: String {
        get {
            model.currentTxRate == 0 ? "N/A" : String(format: "%.0f", model.currentTxRate)
        }
    }
    
    let rateFormater = NumberFormatter()
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Picker("settingsView.label.itemStyle", selection: $model.itemStyle) {
                    Text("settingsView.label.itemStyleOnlyIcon").tag(StatusBarItemStyle.onlyIcon)
                    Text("settingsView.label.itemStyleOnlyTxRate").tag(StatusBarItemStyle.onlyTxRate)
                    Text("settingsView.label.itemStyleIconAndTxRate").tag(StatusBarItemStyle.iconAndTxRate)
                }
                
                Spacer()
            }.padding([.top, .bottom])
            
            HStack(alignment: .center) {
                Text("settingsView.label.limitLabel")
                TextField("settingsView.label.limit", value: $model.rateLimit, formatter: rateFormater)
                    .multilineTextAlignment(.trailing)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Text("settingsView.label.currentRate")
                    .foregroundColor(.secondary)
                Text(currentTxRate)
                    .foregroundColor(.secondary)
                    .frame(width: 40, alignment: .trailing)
                    .padding(0)
                Text("MBit/s")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .padding(0)
            }
            
            Text("settingsView.label.limitExplanation")
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            
            Picker("settingsView.label.action", selection: $model.lowRateAction) {
                Text("settingsView.label.notify").tag(LowRateAction.notify)
                Text("settingsView.label.reconnect").tag(LowRateAction.reconnect)
                Text("settingsView.label.ignore").tag(LowRateAction.ignore)
            }
            
            Spacer()
            
            HStack(alignment: .center) {
                Toggle("settingsView.label.launchAtLogin", isOn: $model.launchAtLogin)
                Spacer()
            }.padding([.top])
            
            HStack(alignment: .center) {
                Spacer()
                Button("settingsView.label.quit", action: self.onQuit)
            }
            
            Spacer()
        }.frame(maxWidth: .infinity, maxHeight: SettingsView.HEIGHT).padding([.horizontal])
    }
    
    private func onQuit() {
        model.onQuit?()
    }
}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(model: SettingsModel())
            .frame(width: SettingsView.WIDTH, height: 195)
    }
}
