//
//  ContentView.swift
//  Circles
//
//  Created by Jacopo Mangiavacchi on 9/14/19.
//  Copyright © 2019 Jacopo Mangiavacchi. All rights reserved.
//

import SwiftUI

let colors = [UIColor.red, UIColor.orange, UIColor.yellow, UIColor.green, UIColor.blue, UIColor.cyan, UIColor.purple, UIColor.brown]

struct CircleRowColData {
    let speed: Int
    let color: UIColor
}

struct CircleState {
    var repeatForever: Bool = false
    var animationTime = 10.0
    var startAngle = 90.0
    var rows:[CircleRowColData] = {
        var array = [CircleRowColData]()
        for i in 0..<8 {
            array.append(CircleRowColData(speed: i + 1, color: colors[i % colors.count]))
        }
        return array
    }()
    var columns:[CircleRowColData] = {
        var array = [CircleRowColData]()
        for i in 0..<3 {
            array.append(CircleRowColData(speed: i + 1, color: colors[i % colors.count]))
        }
        return array
    }()
}

enum CircleType {
    case time, rowcol, figure
}

struct ContentView: View {
    @State var pct: Double = 0.0
    @State var circleState = CircleState()

    var body: some View {
        HStack {
            // Columns
            ForEach((0...self.circleState.columns.count), id: \.self) { c in
                VStack {
                    // Rows
                    ForEach((0...self.circleState.rows.count), id: \.self) { r in
                        Group {
                            if r == 0 && c == 0 {
                                CircleView(circleState: self.$circleState,
                                           type: .time,
                                           pct: self.pct,
                                           text: "\(Int(self.circleState.animationTime))s",
                                           row: CircleRowColData(speed: 1, color: UIColor.white),
                                           col: CircleRowColData(speed: 1, color: UIColor.white))
                            }
                            else if r == 0 {
                                CircleView(circleState: self.$circleState,
                                           type: .rowcol,
                                           pct: self.pct,
                                           text: "\(c)x",
                                           row: self.circleState.columns[c - 1],
                                           col: self.circleState.columns[c - 1])
                            }
                            else if c == 0 {
                                CircleView(circleState: self.$circleState,
                                           type: .rowcol,
                                           pct: self.pct,
                                           text: "\(r)x",
                                           row: self.circleState.rows[r - 1],
                                           col: self.circleState.rows[r - 1])
                            }
                            else {
                                CircleView(circleState: self.$circleState,
                                           type: .figure,
                                           pct: self.pct,
                                           text: "",
                                           row: self.circleState.rows[r - 1],
                                           col: self.circleState.columns[c - 1])
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .onAppear() {
            if self.circleState.repeatForever {
                withAnimation(Animation.linear(duration: self.circleState.animationTime).repeatForever(autoreverses: false)) {
                    self.pct = 1.0
                }
            }
            else {
                withAnimation(Animation.linear(duration: self.circleState.animationTime)) {
                    self.pct = 1.0
                }
            }
        }
    }
}

struct CircleView: View {
    @Binding var circleState: CircleState
    let type: CircleType
    let pct: Double
    let text: String
    let row: CircleRowColData
    let col: CircleRowColData
    let color: Color
    
    struct ModalDetail: Identifiable {
        var id: CircleType {
            return type
        }
        
        let type: CircleType
    }
    @State var detail: ModalDetail?

    init(circleState: Binding<CircleState>, type: CircleType, pct: Double, text: String, row: CircleRowColData, col: CircleRowColData) {
        self._circleState = circleState
        self.type = type
        self.pct = pct
        self.text = text
        self.row = row
        self.col = col
        
        if row.color.cgColor.numberOfComponents < 3 || col.color.cgColor.numberOfComponents < 3 {
            self.color = Color.white
        }
        else {
            let comp1 = row.color.cgColor.components!
            let comp2 = col.color.cgColor.components!

            self.color = Color(red: Double(comp1[0] + comp2[0]) / 2.0,
                         green: Double(comp1[1] + comp2[1]) / 2.0,
                         blue: Double(comp1[2] + comp2[2]) / 2.0)
        }
    }
    
    func modal(detail: CircleType) -> some View {
        Group {
            if detail == .time {
                TimeDetailView(circleState: $circleState) {
                    self.detail = nil
                }
            }
            if detail == .rowcol {
                RowColDetailView() {
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
            CircleShape(pct: pct, startAngle: self.circleState.startAngle, xSpeed: col.speed, ySpeed: row.speed)
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
            for i in 0..<Int(pct*360) {
                x = x_cos[(i * xSpeed) % 360] * scaleX
                y = y_sin[(i * ySpeed) % 360] * scaleY
                p.addLine(to: CGPoint(x: x, y: y))
            }
            
            if pct < 1.0 {
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

struct TimeDetailView: View {
    @Binding var circleState: CircleState
    var onDismiss: () -> ()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Start Angle")) {
                    HStack(alignment: .center) {
                        Text("\(Int(circleState.startAngle))º")
                        Slider(value: $circleState.startAngle, in: 0...360, step: 1)
                    }
                }
                Section(header: Text("Animation")) {
                    Stepper(value: $circleState.animationTime, in: 1...60, label: {
                        Text("Time: \(Int(circleState.animationTime)) sec.")
                        
                    })
                    Toggle(isOn: $circleState.repeatForever) {
                        Text("Repeat Forever")
                    }
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
    var onDismiss: () -> ()
    
    var body: some View {
        VStack {
            Text("RowCol")
            Divider()
            Button(action: { self.onDismiss() }) {
                Text("Dismiss")
            }
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
