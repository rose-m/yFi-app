//
//  SettingsView.swift
//  yFi
//
//  Created by Michael Rose on 09.05.20.
//  Copyright © 2020 Coderose. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    
    @ObservedObject var model: SettingsModel
    
    @State var dummy = "notify"
    
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
            
            Picker(selection: $dummy, label: Text("Action:")) {
                Text("Notify").tag("notify")
                Text("Reconnect").tag("reconnect")
            }.pickerStyle(SegmentedPickerStyle())
            
            Spacer()
        }.frame(width: 200, height: 175).padding([.horizontal])
    }
    
}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(model: SettingsModel())
    }
}
