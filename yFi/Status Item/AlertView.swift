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

struct AlertView : View {
    
    @ObservedObject var model: AlertViewModel
    
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Image(model.icon)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(model.color)
                    .frame(width: 15, height: 15)
                Text(model.content)
                    .frame(maxWidth: .infinity)
            }.padding([.leading, .trailing])
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
}

struct AlertView_Previews: PreviewProvider {
    static var previews: some View {
        AlertView(model: AlertViewModel()).frame(width: 150, height: 30)
    }
}

