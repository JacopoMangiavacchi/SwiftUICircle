//
//  ContentView.swift
//  Circles
//
//  Created by Jacopo Mangiavacchi on 9/14/19.
//  Copyright © 2019 Jacopo Mangiavacchi. All rights reserved.
//

import SwiftUI

var x_cos: [Double] = {
    return (0..<360).map {0.0 + cos(Double($0) * Double.pi/180)}
}()

var y_sin: [Double] = {
    return (0..<360).map {0.0 + sin(Double($0) * Double.pi/180)}
}()


struct ContentView: View {
    var body: some View {
        HStack {
            ForEach((0..<8), id: \.self) {r in
                VStack {
                    ForEach((0..<8), id: \.self) {c in
                        CircleView(r:r, c:c)
                            .stroke(Color.purple, lineWidth: 3)
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
            p.move(to: CGPoint(x: x_cos[358], y: y_sin[358]))

            if r > 0 && c > 0 {
                for i in 0..<360 {
                    let x = x_cos[i * r % 360]
                    let y = y_sin[i * c % 360]
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
