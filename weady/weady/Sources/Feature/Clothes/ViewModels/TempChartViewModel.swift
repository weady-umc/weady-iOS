//
//  TempChartViewModel.swift
//  weady
//
//  Created by 김영택 on 8/9/25.
//

import Foundation
import Combine

struct WeatherResponse: Codable {
    struct HourlyEntry: Codable {
        let dt: TimeInterval
        let temp: Double
    }
    let hourly: [HourlyEntry]
}

class TempChartViewModel: ObservableObject {
    @Published var items: [TempChartModel] = []
    private var cancellables = Set<AnyCancellable>()

    func fetchHourlyTemps(lat: Double, lon: Double, apiKey: String) {
        let urlString = "https://api.openweathermap.org/data/2.5/onecall?lat=\(lat)&lon=\(lon)&exclude=current,minutely,daily,alerts&units=metric&appid=\(apiKey)"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: WeatherResponse.self, decoder: JSONDecoder())
            .map { response in
                response.hourly.map { entry in
                    TempChartModel(
                        date: Date(timeIntervalSince1970: entry.dt),
                        temp: Int(entry.temp.rounded())
                    )
                }
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] chartItems in
                self?.items = chartItems
            })
            .store(in: &cancellables)
    }
}
