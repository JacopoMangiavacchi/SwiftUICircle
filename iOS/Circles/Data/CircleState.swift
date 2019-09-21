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
    var speed: Int
    var color: UIColor
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
    
    var currentRow: Int? = nil
    var currentCol: Int? = nil
    
    var currentRowColColor: Color {
        get {
            guard let col = currentCol, let row = currentRow, col == 0 || row == 0 else { return Color.white }
            
            return Color(col == 0 ? rows[row].color : columns[col].color)
        }

        set {
            guard let col = currentCol, let row = currentRow, col == 0 || row == 0 else { return }

            let newColor = UIColor(hex: newValue.description) ?? UIColor.white
            if col == 0 {
                rows[row].color = newColor
            }
            else {
                columns[col].color = newColor
            }
        }
    }
    
    var currentRowColSpeed: Int {
        get {
            guard let col = currentCol, let row = currentRow, col == 0 || row == 0 else { return 1 }
            
            return col == 0 ? rows[row].speed : columns[col].speed
        }

        set {
            guard let col = currentCol, let row = currentRow, col == 0 || row == 0 else { return }

            if col == 0 {
                rows[row].speed = newValue
            }
            else {
                columns[col].speed = newValue
            }
        }
    }
    
    init(animate: Bool = false, animationTime: Double = 10.0, startAngle: Double = 90.0, rows: [CircleRowColData]? = nil, columns: [CircleRowColData]? = nil) {
        self.animate = animate
        self.animationTime = animationTime
        self.startAngle = startAngle
        self.x_cos = (0..<360).map {1.0 + cos(Double(($0 - Int(startAngle)) % 360) * Double.pi/180)}
        self.y_sin = (0..<360).map {1.0 + sin(Double(($0 - Int(startAngle)) % 360) * Double.pi/180)}
        self.rows = rows ?? CircleState.createDefaultRowCol(count: 7)
        self.columns = columns ?? CircleState.createDefaultRowCol(count: 3)
    }
}


extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
}
