//
//  CircleState.swift
//  Circles
//
//  Created by Jacopo Mangiavacchi on 9/20/19.
//  Copyright © 2019 Jacopo Mangiavacchi. All rights reserved.
//

import SwiftUI
import Combine

let colors = [UIColor.gray, UIColor.red, UIColor.orange, UIColor.yellow, UIColor.green, UIColor.blue, UIColor.cyan, UIColor.purple, UIColor.brown]

enum CircleType {
    case time, rowcol, figure
}

struct CircleRowColData {
    let speed: Int
    let color: UIColor
}

class CircleState: ObservableObject {
    
    static func createDefaultRowCol(count: Int) -> [CircleRowColData] {
        var array = [CircleRowColData]()
        for i in 0...count {
            array.append(CircleRowColData(speed: i > 0 ? i : i + 1, color: colors[i % colors.count]))
        }
        return array
    }

    var animate: Bool
    var animationTime: Double
    @Published var startAngle: Double
    @Published var rows:[CircleRowColData]
    @Published var columns:[CircleRowColData]
    
    var x_cos: [Double]
    var y_sin: [Double]
    
    init(animate: Bool = false, animationTime: Double = 10.0, startAngle: Double = 90.0, rows: [CircleRowColData]? = nil, columns: [CircleRowColData]? = nil) {
        self.animate = animate
        self.animationTime = animationTime
        self.startAngle = startAngle
        self.x_cos = (0..<360).map {1.0 + cos(Double(($0 - Int(startAngle)) % 360) * Double.pi/180)}
        self.y_sin = (0..<360).map {1.0 + sin(Double(($0 - Int(startAngle)) % 360) * Double.pi/180)}
        self.rows = rows ?? CircleState.createDefaultRowCol(count: 8)
        self.columns = columns ?? CircleState.createDefaultRowCol(count: 8)
    }
    
}
