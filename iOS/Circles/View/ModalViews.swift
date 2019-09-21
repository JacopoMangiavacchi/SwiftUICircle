//
//  ModalViews.swift
//  Circles
//
//  Created by Jacopo Mangiavacchi on 9/21/19.
//  Copyright © 2019 Jacopo Mangiavacchi. All rights reserved.
//

import SwiftUI
import Combine
import ColorPicker
import AnglePicker


//final class AngleStore: ObservableObject {
//    @Binding var circleState: CircleState
//
//    init(circleState: Binding<CircleState>) {
//        self._circleState = circleState
//    }
//
//    @Published var selection: Angle = Angle() {
//        didSet {
//            circleState.startAngle = selection.degrees
//        }
//    }
//}

//struct TimeDetailView: View {
//    @Binding var circleState: CircleState
//    @ObservedObject var store: AngleStore
//    let onDismiss: () -> ()
//
//    var body: some View {
//        NavigationView {
//            Form {
//                Section(header: Text("Start Angle")) {
//                    ZStack(alignment: .center) {
//                        AnglePicker(angle: $store.selection, strokeWidth: 20)
//                            .frame(width: 100, height: 100, alignment: .center)
//                            .onAppear() {
//                                self.store.selection.degrees = self.circleState.startAngle
//                            }
//                        Text("\(Int(store.selection.degrees))º")
//                    }
//                }
//                Section(header: Text("Animation")) {
//                    Toggle(isOn: $circleState.animate) {
//                        Text("Animate")
//                    }
////                    Stepper(value: $circleState.animationTime, in: 1...60, label: {
////                        Text("Time: \(Int(circleState.animationTime)) sec.")
////                    })
//                }
//                Section {
//                    Button(action: { self.onDismiss() }) {
//                        Text("Return")
//                    }
//                }
//            }
//            .navigationBarTitle(Text("Settings"))
//        }
//    }
//}


struct RowColDetailView: View {
    @EnvironmentObject var circleState: CircleState
    let onDismiss: () -> ()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Details")) {
//                    Stepper(value: $data.speed, in: 1...10, label: {
//                        Text("Speed: \(Int(data.speed))x")
//                    })
                    ColorPicker(color: $circleState.currentRowColColor, strokeWidth: 20)
                        .frame(width: 100, height: 100, alignment: .center)
                }
                Section {
                    Button(action: {
//                        self.circleState.columns.remove(at: self.col)
                        self.onDismiss()
                    }) {
                        Text("Delete").foregroundColor(.red)
                    }
                    Button(action: {
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
//            .onAppear() {
//                self.color = self.getColor()
//            }
                .navigationBarTitle(Text(circleState.currentRow! == 0 ? "Column \(circleState.currentCol!) Settings" : "Row \(circleState.currentRow!) Settings"))
        }
    }
}

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
