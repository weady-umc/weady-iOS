//
//  RangeBarChartView.swift
//  weady
//
//  Created by 김영택 on 8/9/25.
//

import SwiftUI

struct RangeBarChartView: View {
    let items: [TempChartModel]
    let baseDate: Date
    var labelColor: Color = .white100
    var axisColor: Color = .gray700
    var axisLineWidth: CGFloat = 1.5
    
    private let minTemp = 15
    private let maxTemp = 35
    private let startHour = 8
    private let endHour = 22
    
    private var startDate: Date {
        Calendar.current.date(bySettingHour: startHour, minute: 0, second: 0, of: baseDate)!
    }
    private var totalInterval: TimeInterval { TimeInterval((endHour - startHour) * 3600) }
    
    var body: some View {
        GeometryReader { geo in
            let totalW = geo.size.width
            let totalH = geo.size.height
            
            // 내부 인셋(축/레이블 여유 공간)
            let insetLeft: CGFloat = 30
            let insetBottom: CGFloat = 30
            
            let plotW = max(0, totalW - insetLeft)
            let plotH = max(0, totalH - insetBottom)
            
            let hourSpan = endHour - startHour
            let widthPerHour = plotW / CGFloat(hourSpan)
            
            // 균등 5분할
            let bandCount: CGFloat = 5
            let bandHeight = plotH / bandCount
            let yTickLabels: [Int] = [15, 20, 25, 30, 35]
            let labelWidth: CGFloat = 25
            let sortedItems = items.sorted { $0.date < $1.date }
            
            ZStack(alignment: .bottomLeading) {
                // Y축 그리드라인 및 레이블 (라벨 간격 압축 + 25° 중앙 유지)
                ForEach(0..<yTickLabels.count, id: \.self) { i in
                    let value = yTickLabels[i]
                    let gridY = yForTemp(value, in: plotH) // 0~plotH
                    
                    // 라벨 압축(중앙 기준)
                    let centerY = plotH / 2
                    let labelCompression: CGFloat = 0.8
                    let yLabel = compress(gridY, center: centerY, factor: labelCompression)
                    
                    // 레이블 (y축에서 5pt 왼쪽)
                    Text("\(value)°")
                        .fontName(.metaRegular8)
                        .foregroundColor(labelColor)
                        .frame(width: labelWidth, alignment: .trailing)
                        .position(x: insetLeft - (5 + labelWidth/2), y: yLabel)
                }
                
                // 축 선 (플롯 경계)
                Path { p in
                    // Y축
                    p.move(to: CGPoint(x: insetLeft, y: 0))
                    p.addLine(to: CGPoint(x: insetLeft, y: plotH))
                    // X축
                    p.move(to: CGPoint(x: insetLeft, y: plotH))
                    p.addLine(to: CGPoint(x: insetLeft + plotW, y: plotH))
                }
                .stroke(axisColor, lineWidth: axisLineWidth)
                
                // Bars: 연속 구간 병합 후 렌더링 (라운드 끊김 방지)
                let runs = computeRuns(from: sortedItems)
                ForEach(runs) { run in
                    let xCenter = insetLeft + (CGFloat(run.start) + CGFloat(run.length)/2) * widthPerHour
                    let yTop = plotH - CGFloat(run.band + 1) * bandHeight
                    let barSize = CGSize(width: CGFloat(run.length) * widthPerHour, height: bandHeight)
                    
                    // 막대
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.summerNice)
                        .frame(width: barSize.width, height: barSize.height)
                        .position(x: xCenter, y: yTop + barSize.height/2)
                    
                    // 아이콘 (막대 오른쪽 안쪽 상단)
                    let rightX = xCenter + barSize.width/2
                    let iconX = rightX - 9
                    let iconY = yTop + barSize.height/2 + 3
                    let name = assetName(forBand: run.band)
                    if assetExists(named: name) {
                        Image(name)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                            .position(x: iconX, y: iconY)
                            .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
                            .zIndex(1)
                    } else {
                        Image(systemName: "tshirt")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.appwhite100.opacity(0.9))
                            .position(x: iconX, y: iconY)
                            .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
                            .zIndex(1)
                    }
                }
                
                // X축 레이블
                ForEach([9, 12, 15, 18, 21], id: \.self) { hour in
                    let offsetSec = TimeInterval((hour - startHour) * 3600)
                    let xPos = insetLeft + CGFloat(offsetSec / totalInterval) * plotW
                    Text(labelForHour(hour, on: baseDate))
                        .fontName(.metaRegular8)
                        .foregroundColor(labelColor)
                        .position(x: xPos, y: plotH + 12)
                }
            }
        }
    }
    
    private func labelForHour(_ hour: Int, on date: Date) -> String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "en_US_POSIX")
        fmt.dateFormat = "a h:mm"
        let d = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: date)!
        return fmt.string(from: d)
    }
    
    /// y축 좌표: 값(15~35)을 높이로 선형 매핑 (25°는 중앙)
    private func yForTemp(_ value: Int, in totalHeight: CGFloat) -> CGFloat {
        let minT = CGFloat(minTemp)
        let maxT = CGFloat(maxTemp)
        let v = CGFloat(value)
        let frac = (v - minT) / (maxT - minT) // 0..1 비율
        return totalHeight * (1 - frac)
    }
    
    /// 중심 기준으로 y좌표를 압축/확장 (factor<1: 중앙으로 모임)
    private func compress(_ y: CGFloat, center: CGFloat, factor: CGFloat) -> CGFloat {
        center + (y - center) * factor
    }
    
    // temp를 5개 구간(0~4)으로 매핑
    private func bandIndex(for temp: Int) -> Int {
        switch temp {
        case 15...16: return 0
        case 17...22: return 1
        case 23...26: return 2
        case 27...30: return 3
        case 31...35: return 4
        default: return temp < 15 ? 0 : 4
        }
    }
    
    // 연속 구간 병합용 모델
    private struct Run: Identifiable { let id = UUID(); let band: Int; let start: Int; let length: Int; let iconName: String? }
    
    // items → (hourIndex, band, icon) → 연속 구간 병합
    private func computeRuns(from items: [TempChartModel]) -> [Run] {
        // 1) 시간 필터링 및 변환 (8..21 → 0..13 인덱스)
        let points: [(offset: Int, band: Int, icon: String?)] = items.compactMap { item in
            let delta = item.date.timeIntervalSince(startDate)
            guard delta >= 0 && delta < totalInterval else { return nil }
            let hourIndex = Int(delta / 3600) // 0..13
            return (hourIndex, bandIndex(for: item.temp), item.iconName)
        }.sorted { $0.offset < $1.offset }
        
        // 2) 연속 구간 병합 (밴드와 아이콘이 같을 때만 합치기)
        var runs: [Run] = []
        for p in points {
            if let last = runs.last, last.band == p.band, last.iconName == p.icon, last.start + last.length == p.offset {
                runs[runs.count - 1] = Run(band: last.band, start: last.start, length: last.length + 1, iconName: last.iconName)
            } else {
                runs.append(Run(band: p.band, start: p.offset, length: 1, iconName: p.icon))
            }
        }
        return runs
    }
    // 밴드별 아이콘 매핑 (bar4~bar8)
    private func assetName(forBand band: Int) -> String {
        switch band {
        case 0: return "bar4"   // 15~16
        case 1: return "bar5"   // 17~22
        case 2: return "bar6"   // 23~26
        case 3: return "bar7"   // 27~30
        case 4: return "bar8"   // 31~35
        default: return "bar5"
        }
    }
    
    // 에셋 존재 여부 확인 (없으면 nil)
    private func assetExists(named: String) -> Bool {
#if canImport(UIKit)
        return UIImage(named: named) != nil
#else
        return NSImage(named: named) != nil
#endif
    }
}
