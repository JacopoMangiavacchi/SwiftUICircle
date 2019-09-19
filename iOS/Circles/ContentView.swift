//
//  ContentView.swift
//  Circles
//
//  Created by Jacopo Mangiavacchi on 9/14/19.
//  Copyright © 2019 Jacopo Mangiavacchi. All rights reserved.
//

import SwiftUI

var x_cos: [Double] = {
    return (0..<360).map {1.0 + cos(Double(($0 - 90) % 360) * Double.pi/180)}
}()

var y_sin: [Double] = {
    return (0..<360).map {1.0 + sin(Double(($0 - 90) % 360) * Double.pi/180)}
}()

let colors = [UIColor.red, UIColor.orange, UIColor.yellow, UIColor.green, UIColor.blue, UIColor.cyan, UIColor.purple]

func color(r: Int, c: Int) -> Color {
    if r == 0 && c == 0 {
        return Color.gray
    }
    
    if c == 0 {
        return Color(colors[r - 1])
    }

    if r == 0 {
        return Color(colors[c - 1])
    }
    
    let comp1 = colors[r - 1].cgColor.components!
    let comp2 = colors[c - 1].cgColor.components!

    return Color(red: Double(comp1[0] + comp2[0]) / 2.0,
                 green: Double(comp1[1] + comp2[1]) / 2.0,
                 blue: Double(comp1[2] + comp2[2]) / 2.0)
//    return Color(colors[r - 1].blended(withFraction: 0.5, of: colors[c - 1])!)
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
    
    var body: some View {
        HStack {
            ForEach((0..<8), id: \.self) { r in
                VStack {
                    ForEach((0..<8), id: \.self) { c in
                        Group {
                            if r == 0 && c == 0 {
                                CircleView(pct: self.$pct, modalDisplayed: self.$modalDisplayed, color: Color.white, text: "10s", r: 1, c: 1)
                            }
                            else if r == 0 {
                                CircleView(pct: self.$pct, modalDisplayed: self.$modalDisplayed, color: color(r:r, c:c), text: "\(c)x", r: r, c: c)
                            }
                            else if c == 0 {
                                CircleView(pct: self.$pct, modalDisplayed: self.$modalDisplayed, color: color(r:r, c:c), text: "\(r)x", r: r, c: c)
                            }
                            else {
                                CircleView(pct: self.$pct, modalDisplayed: self.$modalDisplayed, color: color(r:r, c:c), text: "", r: r, c: c)
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
    @Binding var pct: Double
    @Binding var modalDisplayed: Bool
    let color: Color
    let text: String
    let r: Int
    let c: Int

    var body: some View {
        Button(action: { self.modalDisplayed = true }) {
            CircleShape(pct: pct, r:r, c:c)
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
    let r: Int
    let c: Int

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
