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
    public static let HEIGHT: CGFloat = 100.0
    
    @ObservedObject var model: SettingsModel
    
    let rateFormater = NumberFormatter()
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Toggle("Show TX Rate", isOn: $model.showTxRate)
                Spacer()
            }.padding([.top])
            
            HStack(alignment: .center) {
                Text("Limit:")
                TextField("Limit", value: $model.rateLimit, formatter: rateFormater)
                    .multilineTextAlignment(.trailing)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Spacer()
            }.padding([.top])
            
            Text("If the TX rate drops below the limit, we will take action.")
                .foregroundColor(.secondary)
                .frame(height: 40)
            
            Picker("Action:", selection: $model.lowRateAction) {
                Text("Notify").tag(LowRateAction.notify)
                Text("Reconnect").tag(LowRateAction.reconnect)
                Text("Ignore").tag(LowRateAction.ignore)
            }.pickerStyle(SegmentedPickerStyle())
            
            HStack(alignment: .center) {
                Spacer()
                Button("Quit", action: self.onQuit)
            }.padding([.top])
            
            Spacer()
        }.frame(maxWidth: .infinity, maxHeight: .infinity).padding([.horizontal])
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
