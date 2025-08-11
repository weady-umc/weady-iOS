//
//  TemperatureChartView.swift
//  weady
//
//  Created by 김영택 on 8/8/25.
//

import SwiftUI

struct TemperatureChartView: View {
    @StateObject private var vm = TempChartViewModel()
    private let injectedItems: [TempChartModel]?

    /// 기본 API 호출용 초기화
    init() {
        injectedItems = nil
    }

    /// 목업 혹은 뷰모델에서 전달된 데이터용 초기화
    init(chartItems: [ChartItem]) {
        // ChartItem을 TempChartModel로 변환
        injectedItems = chartItems.map { item in
            let date = Calendar.current.date(
                bySettingHour: item.time,
                minute: 0,
                second: 0,
                of: Date()
            )!
            return TempChartModel(date: date, temp: Int(item.feelTmp.rounded()))
        }
    }

    var body: some View {
        let models = injectedItems ?? vm.items
        VStack {
            RangeBarChartView(items: models)
                .frame(width: 320, height: 145)
        }
        .onAppear {
            if injectedItems == nil {
                vm.fetchHourlyTemps(lat: 37.5665, lon: 126.9780, apiKey: "YOUR_API_KEY")
            }
        }
    }
}

struct TemperatureChartView_Previews: PreviewProvider {
    static let mockItems: [TempChartModel] = {
        let calendar = Calendar.current
        let baseDate = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!
        let temps = [16,17,18,19,20,21,22,23,24,25,26,27,28,29]
        return temps.enumerated().map { idx, t in
            let date = calendar.date(byAdding: .hour, value: idx, to: baseDate)!
            return TempChartModel(date: date, temp: t)
        }
    }()

    static var previews: some View {
        RangeBarChartView(items: mockItems)
            .frame(width: 320, height: 145)
            .padding()
    }
}
