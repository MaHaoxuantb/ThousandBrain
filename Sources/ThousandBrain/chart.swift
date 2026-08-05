//
//  graph.swift
//  ThousandBrain
//
//  Created by Thomas B on 8/4/26.
//

import SwiftUI
import Charts

class graph {
    struct ChartPoint: Identifiable {
        let id = UUID()
        let x: String
        let y: Double
    }

    struct ChartWindow: View {
        let data: [ChartPoint]

        var body: some View {
            Chart(data) {
                BarMark(
                    x: .value("X", $0.x),
                    y: .value("Y", $0.y)
                )
            }
            .frame(width: 600, height: 400)
        }
    }
    
    func OpenWindow(title: String, data: [(String, Double)]) {
        let points = data.map {
            ChartPoint(x: $0.0, y: $0.1)
        }

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 400),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )

        window.title = title

        window.contentView = NSHostingView(
            rootView: ChartWindow(data: points)
        )

        window.makeKeyAndOrderFront(nil)
    }
}
