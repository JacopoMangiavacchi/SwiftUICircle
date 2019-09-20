//
//  ContentView.swift
//  Circles
//
//  Created by Jacopo Mangiavacchi on 9/14/19.
//  Copyright © 2019 Jacopo Mangiavacchi. All rights reserved.
//

import SwiftUI
import Combine
import ColorPicker
import AnglePicker

let colors = [UIColor.gray, UIColor.red, UIColor.orange, UIColor.yellow, UIColor.green, UIColor.blue, UIColor.cyan, UIColor.purple, UIColor.brown]

struct CircleRowColData {
    let speed: Int
    let color: UIColor
}

struct CircleState {
    var animate = false {
        didSet {
            pct = animate ? 1.0 : 0.0
        }
    }
    var animation = Animation.linear(duration: 10).repeatForever(autoreverses: false)
    var pct: Double = 0.0
    var animationTime = 10.0 {
        didSet {
            animation = Animation.linear(duration: animationTime).repeatForever(autoreverses: false)
        }
    }
    var startAngle = 90.0
    var rows:[CircleRowColData] = {
        var array = [CircleRowColData]()
        for i in 0...8 {
            array.append(CircleRowColData(speed: i > 0 ? i : i + 1, color: colors[i % colors.count]))
        }
        return array
    }()
    var columns:[CircleRowColData] = {
        var array = [CircleRowColData]()
        for i in 0...6 {
            array.append(CircleRowColData(speed:i > 0 ? i : i + 1, color: colors[i % colors.count]))
        }
        return array
    }()
}

enum CircleType {
    case time, rowcol, figure
}

struct ContentView: View {
    @State private var circleState = CircleState()

    var body: some View {
        HStack {
            // Columns
            ForEach((0..<self.circleState.columns.count), id: \.self) { c in
                VStack {
                    // Rows
                    ForEach((0..<self.circleState.rows.count), id: \.self) { r in
                        Group {
                            if r == 0 && c == 0 {
                                CircleView(circleState: self.$circleState,
                                           type: .time,
                                           text: "", // Temporary disaple animation time "\(Int(self.circleState.animationTime))s",
                                           row: r,
                                           col: c)
                            }
                            else if r == 0 {
                                CircleView(circleState: self.$circleState,
                                           type: .rowcol,
                                           text: "\(self.circleState.columns[c].speed)x",
                                           row: r,
                                           col: c)
                            }
                            else if c == 0 {
                                CircleView(circleState: self.$circleState,
                                           type: .rowcol,
                                           text: "\(self.circleState.rows[r].speed)x",
                                           row: r,
                                           col: c)
                            }
                            else {
                                CircleView(circleState: self.$circleState,
                                           type: .figure,
                                           text: "",
                                           row: r,
                                           col: c)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .onAppear() {
            withAnimation(self.circleState.animation) {
                self.circleState.pct = 1.0
            }
            if !self.circleState.animate {
                self.circleState.pct = 0.0
            }
        }
    }
}

struct CircleView: View {
    @Binding var circleState: CircleState
    let type: CircleType
    let text: String
    let row: Int
    let col: Int
    let rowData: CircleRowColData
    let colData: CircleRowColData
    let color: Color
    
    struct ModalDetail: Identifiable {
        var id: CircleType {
            return type
        }
        
        let type: CircleType
    }
    @State var detail: ModalDetail?

    init(circleState: Binding<CircleState>, type: CircleType, text: String, row: Int, col: Int) {
        self._circleState = circleState
        self.type = type
        self.text = text
        self.row = row
        self.col = col

        var rowData = circleState.wrappedValue.rows[row]
        var colData = circleState.wrappedValue.columns[col]

        if col == 0 {
            rowData = circleState.wrappedValue.rows[row]
            colData = circleState.wrappedValue.rows[row]
            self.color = Color(circleState.wrappedValue.rows[row].color)
        }
        else if row == 0 {
            rowData = circleState.wrappedValue.columns[col]
            colData = circleState.wrappedValue.columns[col]
            self.color = Color(circleState.wrappedValue.columns[col].color)
        }
        else {
            let comp1 = rowData.color.cgColor.components!
            let comp2 = colData.color.cgColor.components!

            self.color = Color(red: Double(comp1[0] + comp2[0]) / 2.0,
                         green: Double(comp1[1] + comp2[1]) / 2.0,
                         blue: Double(comp1[2] + comp2[2]) / 2.0)
        }

        self.rowData = rowData
        self.colData = colData
    }
    
    func modal(detail: CircleType) -> some View {
        Group {
            if detail == .time {
                TimeDetailView(circleState: $circleState, store: AngleStore(circleState: $circleState)) {
                    self.detail = nil
                }
            }
            if detail == .rowcol {
                RowColDetailView(circleState: $circleState, row: row, col: col, data: row == 0 ? $circleState.columns[col] : $circleState.rows[row]) {
                    self.detail = nil
                }
            }
            if detail == .figure {
                FigureDetailView() {
                    self.detail = nil
                }
            }
        }
    }

    var body: some View {
        Button(action: {
            self.detail = ModalDetail(type: self.type)
            
        }) {
            CircleShape(pct: self.circleState.pct, startAngle: self.circleState.startAngle, xSpeed: colData.speed, ySpeed: rowData.speed)
                .stroke(self.color, lineWidth: 2.0)
                .padding(2)
                .overlay(Text(text).foregroundColor(self.color))
        }.sheet(item: $detail, content: { detail in
            self.modal(detail: detail.type)
        })
        .frame(minWidth: 1, maxWidth: .infinity, minHeight: 1, maxHeight: .infinity)
        .aspectRatio(1, contentMode: ContentMode.fit)
    }
}

struct CircleShape: Shape {
    var pct: Double
    let startAngle: Int
    let xSpeed: Int
    let ySpeed: Int
    let x_cos: [Double]
    let y_sin: [Double]
    
    init(pct: Double, startAngle: Double, xSpeed: Int, ySpeed: Int) {
        self.pct = pct
        self.xSpeed = xSpeed
        self.ySpeed = ySpeed
        let iStartAngle = Int(startAngle)
        self.startAngle = iStartAngle
        self.x_cos = (0..<360).map {1.0 + cos(Double(($0 - iStartAngle) % 360) * Double.pi/180)}
        self.y_sin = (0..<360).map {1.0 + sin(Double(($0 - iStartAngle) % 360) * Double.pi/180)}
    }

    func drawFigure(scaleX: Double, scaleY: Double) -> Path {
        return Path { p in
            p.move(to: CGPoint(x: x_cos[359] * scaleX, y: y_sin[359] * scaleY))

            var (x, y) = (0.0, 0.0)
            let pctPositive = pct > 0.0 ? pct : 1.0
            
            for i in 0..<Int(pctPositive*360) {
                x = x_cos[(i * xSpeed) % 360] * scaleX
                y = y_sin[(i * ySpeed) % 360] * scaleY
                p.addLine(to: CGPoint(x: x, y: y))
            }
            
            if pctPositive < 1.0 {
                p.addEllipse(in: CGRect(x: x, y: y, width: 5, height: 5))
                p.addEllipse(in: CGRect(x: x, y: y, width: 10, height: 10))
            }

        }
    }
    
    func path(in rect: CGRect) -> Path {
        let bounds = CGRect(x: 0, y: 0, width: 2, height: 2)
        let scaleX = rect.size.width/bounds.size.width
        let scaleY = rect.size.height/bounds.size.height

        return drawFigure(scaleX: Double(scaleX), scaleY: Double(scaleY))
    }
    
    var animatableData: Double {
        get { return pct }
        set { pct = newValue }
    }
}

final class AngleStore: ObservableObject {
    @Binding var circleState: CircleState

    init(circleState: Binding<CircleState>) {
        self._circleState = circleState
    }
    
    @Published var selection: Angle = Angle() {
        didSet {
            circleState.startAngle = selection.degrees
        }
    }
}

struct TimeDetailView: View {
    @Binding var circleState: CircleState
    @ObservedObject var store: AngleStore
    let onDismiss: () -> ()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Start Angle")) {
                    ZStack(alignment: .center) {
                        AnglePicker(angle: $store.selection, strokeWidth: 20)
                            .frame(width: 100, height: 100, alignment: .center)
                            .onAppear() {
                                self.store.selection.degrees = self.circleState.startAngle
                            }
                        Text("\(Int(store.selection.degrees))º")
                    }
                }
                Section(header: Text("Animation")) {
                    Toggle(isOn: $circleState.animate) {
                        Text("Animate")
                    }
//                    Stepper(value: $circleState.animationTime, in: 1...60, label: {
//                        Text("Time: \(Int(circleState.animationTime)) sec.")
//                    })
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

struct RowColDetailView: View {
    @Binding var circleState: CircleState
    let row: Int
    let col: Int
    @Binding var data: CircleRowColData
    @State var color: Color = .blue
    let onDismiss: () -> ()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Details")) {
//                    Stepper(value: $data.speed, in: 1...10, label: {
                        Text("Speed: \(Int(data.speed))x")
//                    })
                    Text("Color: \(data.color.description)")
                    VStack(alignment: .center) {
//                        Text("Source of truth: \(String(describing: color))")
                        ColorPicker(color: $color, strokeWidth: 20)
                            .frame(width: 100, height: 100, alignment: .center)
                            .onAppear() {
                                self.color = Color(self.data.color)
                            }
                    }
                }
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
