//
//  AlertingView.swift
//  yFi
//
//  Created by Michael Rose on 14.05.20.
//  Copyright © 2020-2023 Coderose. All rights reserved.
//

import SwiftUI
import Foundation
import Combine

struct AlertView : View {
    
    public static let WIDTH: CGFloat = 190.0
    public static let HEIGHT: CGFloat = 30.0
    
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
        AlertView(model: AlertViewModel())
            .frame(width: AlertView.WIDTH, height: AlertView.HEIGHT)
    }
}

