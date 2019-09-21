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
                Section(header: Text("Details")) {
                    Stepper(value: $circleState.currentRowColSpeed, in: 1...10, label: {
                        Text("Speed: \(circleState.currentRowColSpeed)x")
                    })
                    ColorPicker(color: $circleState.currentRowColColor, strokeWidth: 20)
                        .frame(width: 100, height: 100, alignment: .center)
                }
                Section {
                    Button(action: {
                        self.deleteRowCol()
                        self.onDismiss()
                    }) {
                        Text("Delete").foregroundColor(.red)
                    }
                    Button(action: {
                        self.duplicateRowCol()
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
    
    func deleteRowCol() {
        guard let col = circleState.currentCol, let row = circleState.currentRow, col == 0 || row == 0 else { return }

        if col == 0 {
            circleState.rows.remove(at: row)
        }
        else {
            circleState.columns.remove(at: col)
        }
    }

    func duplicateRowCol() {
        guard let col = circleState.currentCol, let row = circleState.currentRow, col == 0 || row == 0 else { return }

        if col == 0 {
            circleState.rows.insert(circleState.rows[row], at: row)
        }
        else {
            circleState.columns.insert(circleState.columns[col], at: col)
        }
    }
}

