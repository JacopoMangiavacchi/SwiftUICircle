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
    var body: some View {
        HStack {
            ForEach((0..<8), id: \.self) {r in
                VStack {
                    ForEach((0..<8), id: \.self) {c in
                        CircleView(r:r, c:c)
                            .stroke(color(r:r, c:c), lineWidth: 2)
                            .padding(2)
                    }
                }
            }
        }
        .padding()
        .aspectRatio(contentMode: ContentMode.fit)
    }
}

struct CircleView: Shape {
    let r: Int
    let c: Int

    func drawFigure() -> Path {
        return Path { p in
            if r > 0 || c > 0 {
                p.move(to: CGPoint(x: x_cos[359], y: y_sin[359]))

                for i in 0..<360 {
                    var ix = i
                    var iy = i
                    
                    if r > 0 && c > 0 {
                        ix *= r
                        iy *= c
                    }

                    let x = x_cos[ix % 360]
                    let y = y_sin[iy % 360]
                    p.addLine(to: CGPoint(x: x, y: y))
                }
            }
        }
    }
    
    func path(in rect: CGRect) -> Path {
        let figure = drawFigure()
        
        let bounds = figure.boundingRect
        let scaleX = rect.size.width/bounds.size.width
        let scaleY = rect.size.height/bounds.size.height
        return figure.applying(CGAffineTransform(scaleX: scaleX, y: scaleY))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
