//
//  CircleView.swift
//  Circles
//
//  Created by Jacopo Mangiavacchi on 9/21/19.
//  Copyright © 2019 Jacopo Mangiavacchi. All rights reserved.
//

import SwiftUI
import Combine

struct CircleView: View {
    @Binding var pct: Double
    let type: CircleType
    let text: String
    let row: Int
    let col: Int
    
    @EnvironmentObject var circleState: CircleState
    
    struct ModalDetail: Identifiable {
        var id: CircleType {
            return type
        }
        
        let type: CircleType
    }
    @State var detail: ModalDetail?

    func presentModalSheet(detail: CircleType) -> some View {
        Group {
//            if detail == .time {
//                TimeDetailView() {
//                    self.detail = nil
//                }
//            }
            if detail == .rowcol {
                RowColDetailView(row: row, col: col) {
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
    
    func circleShapeWrapper() -> some View {
        var rowData = circleState.rows[row]
        var colData = circleState.columns[col]
        var color = Color.white

        if col == 0 {
            rowData = circleState.rows[row]
            colData = circleState.rows[row]
            color = Color(circleState.rows[row].color)
        }
        else if row == 0 {
            rowData = circleState.columns[col]
            colData = circleState.columns[col]
            color = Color(circleState.columns[col].color)
        }
        else {
            let comp1 = rowData.color.cgColor.components!
            let comp2 = colData.color.cgColor.components!

            color = Color(red: Double(comp1[0] + comp2[0]) / 2.0,
                        green: Double(comp1[1] + comp2[1]) / 2.0,
                         blue: Double(comp1[2] + comp2[2]) / 2.0)
        }
        
        let speed = (rowData.speed, colData.speed)
        
        return CircleShape(pct: pct, circleState: circleState, speed: speed)
            .stroke(color, lineWidth: 2.0)
            .padding(2)
            .overlay(Text(text).foregroundColor(color))
    }

    var body: some View {
        Button(action: {
            self.detail = ModalDetail(type: self.type)
        }) {
            circleShapeWrapper()
        }.sheet(item: $detail, content: { detail in
            self.presentModalSheet(detail: detail.type)
        })
        .frame(minWidth: 1, maxWidth: .infinity, minHeight: 1, maxHeight: .infinity)
        .aspectRatio(1, contentMode: ContentMode.fit)
    }
}

