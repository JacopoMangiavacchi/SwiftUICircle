//
//  ContentView.swift
//  Circles
//
//  Created by Jacopo Mangiavacchi on 9/14/19.
//  Copyright © 2019 Jacopo Mangiavacchi. All rights reserved.
//

import SwiftUI

var x_cos: [Double] = {
    return (0..<360).map {1.0 + cos(Double($0) * Double.pi/180)}
}()

var y_sin: [Double] = {
    return (0..<360).map {1.0 + sin(Double($0) * Double.pi/180)}
}()

let colors = [NSColor.red, NSColor.orange, NSColor.yellow, NSColor.green, NSColor.blue, NSColor.cyan, NSColor.purple]

func color(r: Int, c: Int) -> Color {
    if r == 0 && c == 0 {
        return Color.white
    }
    
    if c == 0 {
        return Color(colors[r - 1])
    }

    if r == 0 {
        return Color(colors[c - 1])
    }
    
    return Color(colors[r - 1].blended(withFraction: 0.5, of: colors[c - 1])!)
}

struct ContentView: View {
    @State var pct: Double = 0.0
    
    @State var isPresented = false
    
    var modalPresentation: some View {
        NavigationView {
            Text("Hello World")
                .font(.caption)
//                .navigationBarTitle(Text("Modal Contents"))
//                .navigationBarItems(trailing: Button(action: { self.isPresented = false } ) { Text("Done") })
        }
    }
    
    var body: some View {
        NavigationView {
            HStack {
                ForEach((0..<8), id: \.self) { r in
                    VStack {
                        ForEach((0..<8), id: \.self) { c in
                            Group {
                                if r == 0 && c == 0 {
                                    Button(action: { self.isPresented = true }) {
                                        Text("10")
                                    }
                                    .frame(minWidth: 1, maxWidth: .infinity, minHeight: 1, maxHeight: .infinity)
                                    .background(Color.gray)
                                    .mask(Circle())
                                }
                                else {
                                    CircleView(pct: self.pct, r:r, c:c)
                                        .stroke(color(r:r, c:c), lineWidth: 2.0)
                                        .padding(2)
                                }
                            }
                        }
                    }
                }
            }
            .padding()
            .aspectRatio(contentMode: ContentMode.fit)
            .onAppear() {
                withAnimation(Animation.linear(duration: 10.0).repeatForever(autoreverses: false)) {
                    self.pct = 1.0
                }
            }
        }
        .presentation( isPresented ? Modal(modalPresentation, onDismiss: { self.isPresented.toggle() }) : nil )
    }
}

struct CircleView: Shape {
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
