//
//  FigureDetailView.swift
//  Circles
//
//  Created by Jacopo Mangiavacchi on 9/21/19.
//  Copyright © 2019 Jacopo Mangiavacchi. All rights reserved.
//

import SwiftUI

struct FigureDetailView: View {
    var onDismiss: () -> ()
    
    var body: some View {
        VStack {
            Text("Figure")
            Divider()
            Button(action: { self.onDismiss() }) {
                Text("Dismiss")
            }
        }
    }
}
