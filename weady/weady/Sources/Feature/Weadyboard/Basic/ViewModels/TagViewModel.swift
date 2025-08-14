//
//  TagViewModel.swift
//  weady
//
//  Created by 엄민서 on 8/11/25.
//

import Foundation

@MainActor
final class TagViewModel: ObservableObject {

    // 서버 응답 DTO
    @Published var seasons: [SeasonTagResponseDTO] = []
    @Published var weathers: [WeatherTagResponseDTO] = []
    @Published var temperatures: [TemperatureTagResponseDTO] = []

    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var selectedSeasonIds: Set<Int> = []
    @Published var selectedWeatherIds: Set<Int> = []
    @Published var selectedTemperatureId: Int?


    // 계절
    private let localSeasonOrder: [(id: Int, name: String)] = [
        (1, "봄"), (2, "여름"), (3, "가을"), (4, "겨울")
    ]

    // 날씨
    private let localWeatherOrder: [(id: Int, name: String)] = [
        (1, "맑은 날"),
        (2, "구름 많은 날"),
        (3, "비 오는 날"),
        (4, "흐린 날"),
        (5, "눈 오는 날"),
        (6, "바람 많은 날")
    ]

    // 기온
    private let localTemperatureRanges: [(id: Int, name: String, min: Int?, max: Int?)] = [
        (1, "~ -6℃",        nil,  -6),
        (2, "-5℃ ~ 5℃",     -5,    5),
        (3, "6℃ ~ 11℃",      6,   11),
        (4, "12℃ ~ 16℃",    12,   16),
        (5, "17℃ ~ 22℃",    17,   22),
        (6, "23℃ ~ 26℃",    23,   26),
        (7, "27℃ ~ 30℃",    27,   30),
        (8, "31℃ ~",        31,   nil)
    ]

    // 상태 텍스트 매핑
    func temperatureStatusText(for value: Double) -> String {
        let t = Int(value)
        switch t {
        case ..<(-5): return "한파 수준의 날이에요"
        case -5...5:  return "매우 추운 날이에요"
        case 6...11:  return "쌀쌀한 날이에요"
        case 12...16: return "선선한 날이에요"
        case 17...22: return "따뜻한 날이에요"
        case 23...26: return "다소 더운 날이에요"
        case 27...30: return "더운 날이에요"
        default:      return "폭염 수준의 날이에요"
        }
    }

    // 현재 슬라이더 값에서 “표시용 범위 텍스트”
    func temperatureRangeText(for value: Double) -> String {
        let t = Int(value)
        switch t {
        case ..<(-5): return "~ -6℃"
        case -5...5:  return "-5℃ ~ 5℃"
        case 6...11:  return "6℃ ~ 11℃"
        case 12...16: return "12℃ ~ 16℃"
        case 17...22: return "17℃ ~ 22℃"
        case 23...26: return "23℃ ~ 26℃"
        case 27...30: return "27℃ ~ 30℃"
        default:      return "31℃ ~"
        }
    }

    func temperatureTagId(for sliderValue: Double) -> Int? {
        let t = Int(sliderValue)
        if !temperatures.isEmpty {
            for tag in temperatures {
                if range(Int(tag.minTemperature), Int(tag.maxTemperature), contains: t) {
                    return tag.id
                }
            }
            return nil
        } else {
            for r in localTemperatureRanges {
                if range(r.min, r.max, contains: t) {
                    return r.id
                }
            }
            return nil
        }
    }

    func sliderValue(from tagId: Int) -> Double {
        if let tag = temperatures.first(where: { $0.id == tagId }) {
            return averageOf(min: Int(tag.minTemperature), max: Int(tag.maxTemperature))
        }
        if let r = localTemperatureRanges.first(where: { $0.id == tagId }) {
            return averageOf(min: r.min, max: r.max)
        }
        return 10
    }

    private func range(_ min: Int?, _ max: Int?, contains v: Int) -> Bool {
        if let min { if v < min { return false } }
        if let max { if v > max { return false } }
        return true
    }

    private func averageOf(min: Int?, max: Int?) -> Double {
        switch (min, max) {
        case let (l?, r?): return Double((l + r) / 2)
        case let (l?, nil): return Double(l)
        case let (nil, r?): return Double(r)
        default: return 10
        }
    }

    private let service: TagService

    init(service: TagService = TagService()) {
        self.service = service
    }

    func loadAll(initialCriteria: BoardFilterCriteria) {
        isLoading = true
        errorMessage = nil

        let group = DispatchGroup()

        group.enter()
        service.getSeasonTags { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let data) = result, !data.isEmpty {
                    self?.seasons = data.sorted { $0.id < $1.id }
                } else {
                    self?.seasons = self?.localSeasonOrder.map { SeasonTagResponseDTO(id: $0.id, name: $0.name) } ?? []
                }
                group.leave()
            }
        }

        group.enter()
        service.getWeatherTags { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let data) = result, !data.isEmpty {
                    self?.weathers = data.sorted { $0.id < $1.id }
                } else {
                    self?.weathers = self?.localWeatherOrder.map { WeatherTagResponseDTO(id: $0.id, name: $0.name) } ?? []
                }
                group.leave()
            }
        }

        group.enter()
        service.getTemperatureTags { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let data) = result, !data.isEmpty {
                    self?.temperatures = data.sorted { $0.id < $1.id }
                } else {
                    self?.temperatures = self?.localTemperatureRanges.map {
                        TemperatureTagResponseDTO(id: $0.id, name: $0.name, minTemperature: Double($0.min ?? Int.min), maxTemperature: Double($0.max ?? Int.max))
                    } ?? []
                }
                group.leave()
            }
        }

        group.notify(queue: .main) { [weak self] in
            guard let self else { return }
            self.selectedSeasonIds = initialCriteria.seasonIds
            self.selectedWeatherIds = initialCriteria.weatherIds
            self.selectedTemperatureId = initialCriteria.temperatureTagId
            self.isLoading = false
        }
    }

    func buildCriteria(from sliderValue: Double) -> BoardFilterCriteria {
        BoardFilterCriteria(
            seasonIds: selectedSeasonIds,
            weatherIds: selectedWeatherIds,
            temperatureTagId: temperatureTagId(for: sliderValue)
        )
    }
}
