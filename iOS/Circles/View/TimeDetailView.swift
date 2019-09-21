//
//  ModalViews.swift
//  Circles
//
//  Created by Jacopo Mangiavacchi on 9/21/19.
//  Copyright © 2019 Jacopo Mangiavacchi. All rights reserved.
//

import SwiftUI
import Combine
import AnglePicker


struct TimeDetailView: View {
    @EnvironmentObject var circleState: CircleState
    let onDismiss: () -> ()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Start Angle")) {
                    ZStack(alignment: .center) {
                        AnglePicker(angle: $circleState.startAngle, strokeWidth: 20)
                            .frame(width: 100, height: 100, alignment: .center)
                        Text("\(Int(circleState.startAngle.degrees))º")
                    }
                }
                Section(header: Text("Animation")) {
                    Toggle(isOn: $circleState.animate) {
                        Text("Animate")
                    }
                    Stepper(value: $circleState.animationTime, in: 1...60, label: {
                        Text("Time: \(Int(circleState.animationTime)) sec.")
                    })
                }
                Section {
                    Button(action: { self.onDismiss() }) {
                        Text("Return")
                    }
                }
            }
            .navigationBarTitle(Text("Settings"))
        }
    }
}

