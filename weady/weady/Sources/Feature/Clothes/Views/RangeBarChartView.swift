//
//  RangeBarChartView.swift
//  weady
//
//  Created by 김영택 on 8/9/25.
//

import SwiftUI

struct RangeBarChartView: View {
    let items: [TempChartModel]
    private let minTemp = 15.0
    private let maxTemp = 35.0
    private let startHour = 8
    private let endHour = 22

    private var startDate: Date {
        Calendar.current.startOfDay(for: Date())
            .addingTimeInterval(TimeInterval(startHour * 3600))
    }
    private var totalInterval: TimeInterval {
        TimeInterval((endHour - startHour) * 3600)
    }

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            let hourSpan = endHour - startHour
            let widthPerHour = width / CGFloat(hourSpan)
            let tempRange = maxTemp - minTemp

            ZStack(alignment: .bottomLeading) {
                // Y축 그리드라인 및 레이블
                ForEach(0..<5, id: \.self) { i in
                    let tempValue = minTemp + Double(i) * 5.0
                    let fraction = (tempValue - minTemp) / tempRange
                    let yPos = height * (1 - CGFloat(fraction))
                    // 그리드라인
                    Path { p in
                        p.move(to: CGPoint(x: 0, y: yPos))
                        p.addLine(to: CGPoint(x: width, y: yPos))
                    }
                    .stroke(Color.appgray700.opacity(0.3), lineWidth: 1)
                    // 레이블
                    Text("\(Int(tempValue))°")
                        .fontName(.metaRegular8)
                        .foregroundColor(.appwhite100)
                        .position(x: -20, y: yPos)
                }

                // 축 선
                Path { p in
                    p.move(to: CGPoint(x: 0, y: 0))
                    p.addLine(to: CGPoint(x: 0, y: height))
                    p.move(to: CGPoint(x: 0, y: height))
                    p.addLine(to: CGPoint(x: width, y: height))
                }
                .stroke(Color.appgray700, lineWidth: 2)

                // Bars
                ForEach(items) { item in
                    let delta = item.date.timeIntervalSince(startDate)
                    if delta >= 0 && delta <= totalInterval {
                        let xPos = CGFloat(delta / totalInterval) * width + widthPerHour / 2
                        let minFrac = (Double(item.range.min) - minTemp) / tempRange
                        let maxFrac = (Double(item.range.max) - minTemp) / tempRange
                        let yTop = height * (1 - CGFloat(maxFrac))
                        let barHeight = height * CGFloat(maxFrac - minFrac)

                        Rectangle()
                            .fill(Color.white100)
                            .frame(width: widthPerHour, height: barHeight)
                            .position(x: xPos, y: yTop + barHeight / 2)
                            .cornerRadius(2)
                    }
                }

                // X축 레이블
                ForEach([9, 12, 15, 18, 21], id: \.self) { hour in
                    let offsetSec = TimeInterval((hour - startHour) * 3600)
                    let xPos = CGFloat(offsetSec / totalInterval) * width
                    Text(labelForHour(hour))
                        .fontName(.metaRegular8)
                        .foregroundColor(.appwhite100)
                        .position(x: xPos, y: height + 12)
                }
            }
        }
        .padding(.leading, 30)
        .padding(.bottom, 30)
        .frame(height: 120)
    }

    private func labelForHour(_ hour: Int) -> String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "en_US_POSIX")
        fmt.dateFormat = "a h:mm"
        let d = Calendar.current.startOfDay(for: Date())
            .addingTimeInterval(TimeInterval(hour * 3600))
        return fmt.string(from: d)
    }
}
