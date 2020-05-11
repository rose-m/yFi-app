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
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Toggle("Show TX Rate", isOn: $model.showTxRate)
                Spacer()
            }
            Spacer()
        }.frame(width: 200, height: 150).padding()
    }
    
}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(model: SettingsModel())
    }
}
