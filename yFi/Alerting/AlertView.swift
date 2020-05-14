//
//  AlertingView.swift
//  yFi
//
//  Created by Michael Rose on 14.05.20.
//  Copyright © 2020 Coderose. All rights reserved.
//

import SwiftUI
import Foundation

struct AlertView : View {
    
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Image("icon-warning")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(.yellow)
                    .frame(width: 15, height: 15)
                Text("Bad WiFi quality...")
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
}

struct AlertView_Previews: PreviewProvider {
    static var previews: some View {
        AlertView().frame(width: 150, height: 30)
    }
}

