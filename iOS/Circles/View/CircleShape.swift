//
//  CircleShape.swift
//  Circles
//
//  Created by Jacopo Mangiavacchi on 9/21/19.
//  Copyright © 2019 Jacopo Mangiavacchi. All rights reserved.
//

import SwiftUI

struct CircleShape: Shape {
    var pct: Double
    var circleState: CircleState
    let speed: (x: Int, y: Int)

    func drawFigure(scaleX: Double, scaleY: Double) -> Path {
        return Path { p in
            p.move(to: CGPoint(x: circleState.x_cos[359] * scaleX, y: circleState.y_sin[359] * scaleY))

            var (x, y) = (0.0, 0.0)
            let pctPositive = pct > 0.0 ? pct : 1.0
            
            for i in 0..<Int(pctPositive*360) {
                x = circleState.x_cos[(i * speed.x) % 360] * scaleX
                y = circleState.y_sin[(i * speed.y) % 360] * scaleY
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
