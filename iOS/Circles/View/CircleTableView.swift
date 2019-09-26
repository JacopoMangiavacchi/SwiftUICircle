//
//  CircleTableView.swift
//  Circles
//
//  Created by Jacopo Mangiavacchi on 9/26/19.
//  Copyright © 2019 Jacopo Mangiavacchi. All rights reserved.
//

import SwiftUI
import Combine

// Workaround: Duplicated CircleTableViewAnimate and CircleTableViewNoAnimate views
//             in order to let the animation binding works

struct CircleTableViewAnimate: View {
    @EnvironmentObject var circleState: CircleState
    @State var pct = 0.0
    
    var body: some View {
        HStack {
            // Columns
            ForEach((0..<self.circleState.columns.count), id: \.self) { c in
                VStack {
                    // Rows
                    ForEach((0..<self.circleState.rows.count), id: \.self) { r in
                        Group {
                            if r == 0 && c == 0 {
                                ZStack {
                                    Image(systemName: "goforward")
                                        .foregroundColor(.gray)
                                    CircleView(pct: self.$pct,
                                               type: .time,
                                               text: "", // Temporary disable animation time "\(Int(self.circleState.animationTime))s",
                                               row: r,
                                               col: c)
                                }
                            }
                            else if r == 0 {
                                CircleView(pct: self.$pct,
                                           type: .rowcol,
                                           text: "\(self.circleState.columns[c].speed)x",
                                           row: r,
                                           col: c)
                            }
                            else if c == 0 {
                                CircleView(pct: self.$pct,
                                           type: .rowcol,
                                           text: "\(self.circleState.rows[r].speed)x",
                                           row: r,
                                           col: c)
                            }
                            else {
                                CircleView(pct: self.$pct,
                                           type: .figure,
                                           text: "",
                                           row: r,
                                           col: c)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .onAppear() {
            withAnimation(Animation.linear(duration: self.circleState.animationTime).repeatForever(autoreverses: false)) {
                self.pct = 1.0
            }
        }
    }
}

struct CircleTableViewNoAnimate: View {
    @EnvironmentObject var circleState: CircleState
    @State var pct = 0.0
    
    var body: some View {
        HStack {
            // Columns
            ForEach((0..<self.circleState.columns.count), id: \.self) { c in
                VStack {
                    // Rows
                    ForEach((0..<self.circleState.rows.count), id: \.self) { r in
                        Group {
                            if r == 0 && c == 0 {
                                ZStack {
                                    Image(systemName: "goforward")
                                        .foregroundColor(.gray)
                                    CircleView(pct: self.$pct,
                                               type: .time,
                                               text: "", // Temporary disable animation time "\(Int(self.circleState.animationTime))s",
                                               row: r,
                                               col: c)
                                }
                            }
                            else if r == 0 {
                                CircleView(pct: self.$pct,
                                           type: .rowcol,
                                           text: "\(self.circleState.columns[c].speed)x",
                                           row: r,
                                           col: c)
                            }
                            else if c == 0 {
                                CircleView(pct: self.$pct,
                                           type: .rowcol,
                                           text: "\(self.circleState.rows[r].speed)x",
                                           row: r,
                                           col: c)
                            }
                            else {
                                CircleView(pct: self.$pct,
                                           type: .figure,
                                           text: "",
                                           row: r,
                                           col: c)
                            }
                        }
                    }
                }
            }
        }
        .padding()
    }
}
