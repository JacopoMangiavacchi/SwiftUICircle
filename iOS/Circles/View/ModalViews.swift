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
    let row: Int
    let col: Int
    @EnvironmentObject var circleState: CircleState
    @State var color: Color = .blue
    let onDismiss: () -> ()
    
    var body: some View {
        NavigationView {
            Form {
//                Section(header: Text("Details")) {
////                    Stepper(value: $data.speed, in: 1...10, label: {
//                        Text("Speed: \(Int(data.speed))x")
////                    })
//                    Text("Color: \(data.color.description)")
//                    VStack(alignment: .center) {
////                        Text("Source of truth: \(String(describing: color))")
//                        ColorPicker(color: $color, strokeWidth: 20)
//                            .frame(width: 100, height: 100, alignment: .center)
//                            .onAppear() {
//                                self.color = Color(self.data.color)
//                            }
//                    }
//                }
                Section {
                    Button(action: {
                        self.circleState.columns.remove(at: self.col)
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
                    Button(action: { self.onDismiss() }) {
                        Text("Return")
                    }
                }
            }
            .navigationBarTitle(Text(row == 0 ? "Column \(col)" : "Row \(row)"))
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
