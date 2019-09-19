//
//  ContentView.swift
//  Circles
//
//  Created by Jacopo Mangiavacchi on 9/14/19.
//  Copyright © 2019 Jacopo Mangiavacchi. All rights reserved.
//

import SwiftUI

let colors = [UIColor.white, UIColor.red, UIColor.orange, UIColor.yellow, UIColor.green, UIColor.blue, UIColor.cyan, UIColor.purple]

struct CircleData {
    let speed: Int
    let color: UIColor
}

struct DetailView: View {
    var onDismiss: () -> ()
    
    var body: some View {
        Button(action: { self.onDismiss() }) {
            Text("Dismiss")
        }
    }
}

struct ContentView: View {
    @State var pct: Double = 0.0
    @State var animationTime = 10.0
    @State var modalDisplayed = false
    @State var startAngle = 90
    @State var rows:[CircleData] = {
        var array = [CircleData]()
        for i in 1...7 {
            array.append(CircleData(speed: i, color: colors[i]))
        }
        return array
    }()
    @State var columns:[CircleData] = {
        var array = [CircleData]()
        for i in 1...7 {
            array.append(CircleData(speed: i, color: colors[i]))
        }
        return array
    }()

    func color(r: Int, c: Int) -> Color {
        if c == 0 {
            return Color(colors[r])
        }

        if r == 0 {
            return Color(colors[c])
        }
        
        let comp1 = colors[r].cgColor.components!
        let comp2 = colors[c].cgColor.components!

        return Color(red: Double(comp1[0] + comp2[0]) / 2.0,
                     green: Double(comp1[1] + comp2[1]) / 2.0,
                     blue: Double(comp1[2] + comp2[2]) / 2.0)
    }

    var body: some View {
        HStack {
            ForEach((0..<8), id: \.self) { r in
                VStack {
                    ForEach((0..<8), id: \.self) { c in
                        Group {
                            if r == 0 && c == 0 {
                                CircleView(modalDisplayed: self.$modalDisplayed, pct: self.pct, startAngle: self.startAngle, color: self.color(r:0, c:0), text: "10s", r: 1, c: 1)
                            }
                            else if r == 0 {
                                CircleView(modalDisplayed: self.$modalDisplayed, pct: self.pct, startAngle: self.startAngle, color: self.color(r:r, c:c), text: "\(c)x", r: r, c: c)
                            }
                            else if c == 0 {
                                CircleView(modalDisplayed: self.$modalDisplayed, pct: self.pct, startAngle: self.startAngle, color: self.color(r:r, c:c), text: "\(r)x", r: r, c: c)
                            }
                            else {
                                CircleView(modalDisplayed: self.$modalDisplayed, pct: self.pct, startAngle: self.startAngle, color: self.color(r:r, c:c), text: "", r: r, c: c)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .onAppear() {
            withAnimation(Animation.linear(duration: self.animationTime).repeatForever(autoreverses: false)) {
                self.pct = 1.0
            }
        }
    }
}

struct CircleView: View {
    @Binding var modalDisplayed: Bool
    let pct: Double
    let startAngle: Int
    let color: Color
    let text: String
    let r: Int
    let c: Int

    var body: some View {
        Button(action: { self.modalDisplayed = true }) {
            CircleShape(pct: pct, startAngle: self.startAngle, r:r, c:c)
                .stroke(color, lineWidth: 2.0)
                .padding(2)
                .overlay(Text(text).foregroundColor(color))
        }.sheet(isPresented: self.$modalDisplayed) {
            DetailView(onDismiss: {
                self.modalDisplayed = false
            })
        }
        .frame(minWidth: 1, maxWidth: .infinity, minHeight: 1, maxHeight: .infinity)
        .aspectRatio(1, contentMode: ContentMode.fit)
    }
}

struct CircleShape: Shape {
    var pct: Double
    let startAngle: Int
    let r: Int
    let c: Int
    let x_cos: [Double]
    let y_sin: [Double]
    
    init(pct: Double, startAngle: Int, r: Int, c: Int) {
        self.pct = pct
        self.r = r
        self.c = c
        self.startAngle = startAngle
        self.x_cos = (0..<360).map {1.0 + cos(Double(($0 - startAngle) % 360) * Double.pi/180)}
        self.y_sin = (0..<360).map {1.0 + sin(Double(($0 - startAngle) % 360) * Double.pi/180)}
    }

    func drawFigure(scaleX: Double, scaleY: Double) -> Path {
        return Path { p in
            if r > 0 || c > 0 {
                p.move(to: CGPoint(x: x_cos[359] * scaleX, y: y_sin[359] * scaleY))

                var (x, y) = (0.0, 0.0)
                for i in 0..<Int(pct*360) {
                    var ix = i
                    var iy = i
                    
                    if r == 0 {
                        ix *= c
                        iy *= c

                    }
                    else if c == 0 {
                        ix *= r
                        iy *= r
                    }
                    else {
                        ix *= r
                        iy *= c
                    }

                    x = x_cos[ix % 360] * scaleX
                    y = y_sin[iy % 360] * scaleY
                    p.addLine(to: CGPoint(x: x, y: y))
                }
                
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
