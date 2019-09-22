//
//  FigureDetailView.swift
//  Circles
//
//  Created by Jacopo Mangiavacchi on 9/21/19.
//  Copyright © 2019 Jacopo Mangiavacchi. All rights reserved.
//

import SwiftUI

struct FigureDetailView: View {
    @EnvironmentObject var circleState: CircleState
    @State var pct = 0.0

    var onDismiss: () -> ()
    
    var body: some View {
        VStack {
            CircleShape(pct: self.pct, circleState: circleState, speed: circleState.currentSpeed)
                .stroke(self.circleState.currentColor, lineWidth: 4.0)
                .padding(10)
                .frame(minWidth: 1, maxWidth: .infinity, minHeight: 1, maxHeight: .infinity)
                .aspectRatio(1, contentMode: ContentMode.fit)
                .onAppear() {
                    withAnimation(Animation.linear(duration: self.circleState.animationTime).repeatForever(autoreverses: false)) {
                        self.pct = 1.0
                    }
                }

            Button(action: { self.onDismiss() }) {
                Text("Dismiss")
            }
        }
    }
}
