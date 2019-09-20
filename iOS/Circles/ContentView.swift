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

enum CircleType {
    case time, rowcol, figure
}

struct ContentView: View {
    @State var pct: Double = 0.0
    @State var repeatForever: Bool = true
    @State var animationTime = 10.0
    @State var startAngle = 90
    @State var rows:[CircleRowColData] = {
        var array = [CircleRowColData]()
        for i in 0..<8 {
            array.append(CircleRowColData(speed: i + 1, color: colors[i % colors.count]))
        }
        return array
    }()
    @State var columns:[CircleRowColData] = {
        var array = [CircleRowColData]()
        for i in 0..<3 {
            array.append(CircleRowColData(speed: i + 1, color: colors[i % colors.count]))
        }
        return array
    }()

    var body: some View {
        HStack {
            // Columns
            ForEach((0...self.columns.count), id: \.self) { c in
                VStack {
                    // Rows
                    ForEach((0...self.rows.count), id: \.self) { r in
                        Group {
                            if r == 0 && c == 0 {
                                CircleView(type: .time,
                                           pct: self.pct,
                                           startAngle: self.startAngle,
                                           text: "10s",
                                           row: CircleRowColData(speed: 1, color: UIColor.white),
                                           col: CircleRowColData(speed: 1, color: UIColor.white))
                            }
                            else if r == 0 {
                                CircleView(type: .rowcol,
                                           pct: self.pct,
                                           startAngle: self.startAngle,
                                           text: "\(c)x",
                                           row: self.columns[c - 1],
                                           col: self.columns[c - 1])
                            }
                            else if c == 0 {
                                CircleView(type: .rowcol,
                                           pct: self.pct,
                                           startAngle: self.startAngle,
                                           text: "\(r)x",
                                           row: self.rows[r - 1],
                                           col: self.rows[r - 1])
                            }
                            else {
                                CircleView(type: .figure,
                                           pct: self.pct,
                                           startAngle: self.startAngle,
                                           text: "",
                                           row: self.rows[r - 1],
                                           col: self.columns[c - 1])
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .onAppear() {
            if self.repeatForever {
                withAnimation(Animation.linear(duration: self.animationTime).repeatForever(autoreverses: false)) {
                    self.pct = 1.0
                }
            }
            else {
                withAnimation(Animation.linear(duration: self.animationTime)) {
                    self.pct = 1.0
                }
            }
        }
    }
}

struct CircleView: View {
    let type: CircleType
    let pct: Double
    let startAngle: Int
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

    init(type: CircleType, pct: Double, startAngle: Int, text: String, row: CircleRowColData, col: CircleRowColData) {
        self.type = type
        self.pct = pct
        self.startAngle = startAngle
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
                TimeDetailView() {
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
            CircleShape(pct: pct, startAngle: self.startAngle, xSpeed: col.speed, ySpeed: row.speed)
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
    
    init(pct: Double, startAngle: Int, xSpeed: Int, ySpeed: Int) {
        self.pct = pct
        self.xSpeed = xSpeed
        self.ySpeed = ySpeed
        self.startAngle = startAngle
        self.x_cos = (0..<360).map {1.0 + cos(Double(($0 - startAngle) % 360) * Double.pi/180)}
        self.y_sin = (0..<360).map {1.0 + sin(Double(($0 - startAngle) % 360) * Double.pi/180)}
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
    var onDismiss: () -> ()
    
    var body: some View {
        VStack {
            Text("Time")
            Divider()
            Button(action: { self.onDismiss() }) {
                Text("Dismiss")
            }
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
