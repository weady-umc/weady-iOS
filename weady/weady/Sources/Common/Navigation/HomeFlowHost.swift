//
//  HomeFlowHost.swift
//  weady
//
//  Created by 엄민서 on 8/9/25.
//

import SwiftUI
import Observation

enum HomeRoute: Hashable {
    case root
    case weatherAddLocation
    case weatherSearch
    case weatherLocation
}

@Observable
final class HomeRouter {
    var path = NavigationPath()
    func push(_ route: HomeRoute) { path.append(route) }
    func pop() { if !path.isEmpty { path.removeLast() } }
    func reset() { path = NavigationPath() }
}

struct HomeFlowHost: View {
    @State private var router = HomeRouter()

    var body: some View {
        NavigationStack(path: $router.path) {
            HomeView()
                .navigationDestination(for: HomeRoute.self) { route in
                    switch route {
                    case .root:
                        HomeView()
                    case .weatherAddLocation:
                        WeatherLocationAddView(
                            viewModel: WeatherLocationAddViewModel(),
                            locationViewModel: WeatherLocationViewModel(),
                            selectedPlace: .constant(nil),
                            weather: ShortWeatherData.example
                        )
                    case .weatherSearch:
                        WeatherSearchView(selectedPlace: .constant(nil))
                    case .weatherLocation:
                        WeatherLocationView()
                    }
                }
        }
        .environment(router)
    }
}