//
//  graph.swift
//  ThousandBrain
//
//  Created by Thomas B on 8/4/26.
//

import SwiftUI
import Charts
import AppKit

final class BarChartViewer {
    struct ChartPoint: Identifiable {
        let id = UUID()
        let x: Double
        let y: Double
    }

    @available(macOS 13.0, *)
    struct ChartWindow: View {
        let data: [ChartPoint]

        private func paddedDomain(for values: [Double]) -> ClosedRange<Double> {
            guard let minimum = values.min(), let maximum = values.max() else {
                return 0...1
            }

            let span = maximum - minimum
            let padding = span > 0
                ? max(span * 0.05, 1)
                : max(abs(minimum) * 0.05, 1)

            return (minimum - padding)...(maximum + padding)
        }

        var body: some View {
            ZStack {
                VStack {
                    Text("Continue other processes by closing this window.")
                        .foregroundStyle(Color.gray.opacity(0.4))
                    Spacer()
                    Text("©2026 ThomasB. ThousandBrain.")
                        .foregroundStyle(Color.gray.opacity(0.4))
                }
                
                VStack(alignment: .center) {
                    Chart(data) {
                        BarMark(
                            x: .value("X", $0.x),
                            y: .value("Y", $0.y)
                        )
                    }
                    .foregroundStyle(Color.yellow)
                    .chartXScale(domain: paddedDomain(for: data.map(\.x)))
                    .chartYScale(domain: paddedDomain(for: data.map(\.y)))
                    .frame(width: 600, height: 400)
                }
            }
            .frame(width: 600, height: 500)
        }
    }
    
    func OpenBarChart(title: String, data: [(Int32, Int32)]) {
        guard #available(macOS 13.0, *) else {
            print("Charts require macOS 13.0 or newer.")
            return
        }

        MainActor.assumeIsolated {
            let app = NSApplication.shared
            app.setActivationPolicy(.regular)

            let points = data.map {
                ChartPoint(x: Double($0.0), y: Double($0.1))
            }

            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 600, height: 500),
                styleMask: [.titled, .closable, .resizable],
                backing: .buffered,
                defer: false
            )

            window.title = title
            window.contentView = NSHostingView(
                rootView: ChartWindow(data: points)
            )

            window.center()
            window.makeKeyAndOrderFront(nil)
            app.activate(ignoringOtherApps: true)

            while window.isVisible {
                if let event = app.nextEvent(
                    matching: .any,
                    until: .distantFuture,
                    inMode: .default,
                    dequeue: true
                ) {
                    app.sendEvent(event)
                }
            }
        }
    }
}
