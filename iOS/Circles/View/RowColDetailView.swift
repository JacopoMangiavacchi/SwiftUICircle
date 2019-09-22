//
//  RowColDetailView.swift
//  Circles
//
//  Created by Jacopo Mangiavacchi on 9/21/19.
//  Copyright © 2019 Jacopo Mangiavacchi. All rights reserved.
//

import SwiftUI
import Combine
import ColorPicker

struct RowColDetailView: View {
    @EnvironmentObject var circleState: CircleState
    let onDismiss: () -> ()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Speed")) {
                    Stepper(value: $circleState.currentRowColSpeed, in: 1...10, label: {
                        Text("Speed: \(circleState.currentRowColSpeed)x")
                    })
                }
                Section(header: Text("Color")) {
                    ColorPicker(color: $circleState.currentRowColColor, strokeWidth: 30)
                        .frame(width: 200, height: 200, alignment: .center)
                }
                Section(header: Text("Actions")) {
                    if self.circleState.canDeleteCurrentRowCol() {
                        Button(action: {
                            self.circleState.deleteCurrentRowCol()
                            self.onDismiss()
                        }) {
                            Text("Delete").foregroundColor(.red)
                        }
                    }
                    Button(action: {
                        self.circleState.duplicateCurrentRowCol()
                        self.onDismiss()
                    }) {
                        Text("Duplicate").foregroundColor(.green)
                    }
                }
                Section {
                    Button(action: {
                        self.onDismiss()
                    }) {
                        Text("Return")
                    }
                }
            }
            .navigationBarTitle(Text(circleState.currentRow! == 0 ? "Column \(circleState.currentCol!) Settings" : "Row \(circleState.currentRow!) Settings"))
        }
    }
}

