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

class ColorCodable: Codable {
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    var alpha: CGFloat = 0.0
    
    init(color:UIColor) {
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    }

    var color:UIColor{
        get{
            return UIColor(red: red, green: green, blue: blue, alpha: alpha)
        }
        set{
            newValue.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        }
    }
}

struct CircleRowColData: Codable {
    var speed: Int
    var color: ColorCodable
}

private var cancellables = [String:AnyCancellable]()

extension Published where Value : Codable {
    init(wrappedValue defaultValue: Value, key: String) {
        var value = defaultValue
        
        if let savedData = UserDefaults.standard.object(forKey: key) as? Data {
            let decoder = JSONDecoder()
            if let loadedData = try? decoder.decode(Value.self, from: savedData) {
                value = loadedData
            }
        }
        self.init(initialValue: value)

        cancellables[key] = projectedValue.sink { val in
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(val) {
                UserDefaults.standard.set(encoded, forKey: key)
            }
        }
    }
}

class CircleState: ObservableObject {
    
    static func createDefaultRowCol(count: Int) -> [CircleRowColData] {
        var array = [CircleRowColData]()
        for i in 0...count {
            array.append(CircleRowColData(speed: i > 0 ? i : i + 1, color: ColorCodable(color: colors[i % colors.count])))
        }
        return array
    }
    
    static func getX_CosArray(angle: Int) -> [Double] {
        (0..<360).map {1.0 + cos(Double(($0 - angle) % 360) * Double.pi/180)}
    }

    static func getY_SinArray(angle: Int) -> [Double] {
        (0..<360).map {1.0 + sin(Double(($0 - angle) % 360) * Double.pi/180)}
    }

    @Published(key: "animate") var animate: Bool = false
    @Published(key: "animationTime") var animationTime: Double = 10.0
    @Published(key: "startAngle") var savedStartAngle: Double = 90
    @Published var startAngle: Angle {
        didSet {
            self.savedStartAngle = startAngle.degrees
            self.x_cos = CircleState.getX_CosArray(angle: Int(startAngle.degrees))
            self.y_sin = CircleState.getY_SinArray(angle: Int(startAngle.degrees))
        }
    }
    @Published(key: "rows") var rows:[CircleRowColData] = []
    @Published(key: "columns") var columns:[CircleRowColData] = []
    
    @Published var x_cos: [Double]
    @Published var y_sin: [Double]
    
    var currentRow: Int? = nil
    var currentCol: Int? = nil

    var currentColor: Color {
        get {
            guard let col = currentCol, let row = currentRow, col > 0 && row > 0 && row < rows.count && col < columns.count else { return Color.white }
            
            let comp1 = rows[row].color.color.cgColor.components!
            let comp2 = columns[col].color.color.cgColor.components!

            return Color(red: Double(comp1[0] + comp2[0]) / 2.0,
                        green: Double(comp1[1] + comp2[1]) / 2.0,
                         blue: Double(comp1[2] + comp2[2]) / 2.0)
        }
    }
    
    var currentRowColColor: Color {
        get {
            guard let col = currentCol, let row = currentRow, (col == 0 || row == 0) && row < rows.count && col < columns.count else { return Color.white }
            
            return Color(col == 0 ? rows[row].color.color : columns[col].color.color)
        }

        set {
            guard let col = currentCol, let row = currentRow, col == 0 || row == 0 else { return }

            let newColor = UIColor(hex: newValue.description) ?? UIColor.white
            if col == 0 {
                rows[row].color = ColorCodable(color: newColor)
            }
            else {
                columns[col].color = ColorCodable(color: newColor)
            }
        }
    }
    
    var currentSpeed: (Int, Int) {
        get {
            guard let col = currentCol, let row = currentRow, col > 0 && row > 0 && row < rows.count && col < columns.count else { return (1, 1) }
            
            return (rows[row].speed, columns[col].speed)
        }
    }

    var currentRowColSpeed: Int {
        get {
            guard let col = currentCol, let row = currentRow, (col == 0 || row == 0) && row < rows.count && col < columns.count else { return 1 }
            
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
    
    init() {
        self.x_cos = CircleState.getX_CosArray(angle: 0)
        self.y_sin = CircleState.getY_SinArray(angle: 0)
        self.startAngle = Angle(degrees: 0)

        if self.rows.count == 0 {
            self.rows = CircleState.createDefaultRowCol(count: 7)
        }
        if self.columns.count == 0 {
            self.columns = CircleState.createDefaultRowCol(count: 3)
        }
        
        self.startAngle = Angle(degrees: savedStartAngle)
        self.x_cos = CircleState.getX_CosArray(angle: Int(startAngle.degrees))
        self.y_sin = CircleState.getY_SinArray(angle: Int(startAngle.degrees))
    }
    
    func resetAllRowsCols() {
        self.rows = CircleState.createDefaultRowCol(count: 7)
        self.columns = CircleState.createDefaultRowCol(count: 3)
    }
    
    func canDeleteCurrentRowCol() -> Bool {
        guard let col = self.currentCol, let row = self.currentRow, col == 0 || row == 0 else { return false }

        if col == 0 {
            return self.rows.count > 2
        }
        else {
            return self.columns.count > 2
        }
    }
    
    func deleteCurrentRowCol() {
        guard let col = self.currentCol, let row = self.currentRow, col == 0 || row == 0 else { return }

        if col == 0 {
            self.rows.remove(at: row)
        }
        else {
            self.columns.remove(at: col)
        }
    }

    func duplicateCurrentRowCol() {
        guard let col = self.currentCol, let row = self.currentRow, col == 0 || row == 0 else { return }

        if col == 0 {
            self.rows.insert(self.rows[row], at: row)
        }
        else {
            self.columns.insert(self.columns[col], at: col)
        }
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
