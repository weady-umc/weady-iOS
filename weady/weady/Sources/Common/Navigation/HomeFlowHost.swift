//
//  HomeFlowHost.swift
//  weady
//
//  Created by 엄민서 on 8/9/25.
//

import SwiftUI
import Observation

// MARK: - HomeRoute
/// Home 플로우에서 사용하는 라우트 정의
enum HomeRoute: Hashable {
    case home
    case weatheradd(AddressDocument, ShortWeatherData)
    case weathersearch
    case weatherlocation

    case weatherhome
    case clothes

    case curationdetail(curationId: Int64)
    case curation
    
    case alarm
    case weadyboard
}

// MARK: - HomeRouter
/// 홈 플로우의 NavigationPath와 push/pop/reset 제공
final class HomeRouter: ObservableObject {
    // MARK: Properties
    @Published var path = NavigationPath()

    // MARK: Navigation Actions
    func push(_ route: HomeRoute) { path.append(route) }
    func pop() { if !path.isEmpty { path.removeLast() } }
    func popToRoot() { path = NavigationPath() }
}

struct HomeFlowHost: View {
    @StateObject private var homeRouter = HomeRouter()
    @Binding var isTabBarHidden: Bool

    var body: some View {
        NavigationStack(path: $homeRouter.path) {
            HomeEntryView()
                .navigationDestination(for: HomeRoute.self) { route in
                    switch route {
                    case .home:
                        HomeEntryView()

                    case .weatherhome:
                        WeatherHomeView()
                    case .weatheradd(let place, let weather):
                        WeatherLocationAddView(
                            viewModel: WeatherLocationAddViewModel(),
                            locationViewModel: WeatherLocationViewModel(),
                            selectedPlace: .constant(place),
                            onComplete: {
                                homeRouter.path = NavigationPath()
                                homeRouter.path.append(HomeRoute.weatherlocation)
                            },
                            weather: weather
                        )
                    case .weathersearch:
                        WeatherSearchView(selectedPlace: .constant(nil))
                    case .weatherlocation:
                        WeatherLocationView()

                    case .clothes:
                        ClothingRecommendationView()

                    case .curationdetail(let curationId):
                        DetailCurationView(curationId: curationId,isTabBarHidden: $isTabBarHidden)
                    case .curation:
                        CurationView()
                    case .alarm:
                        NotificationView()
                    case .weadyboard:
                        WeadyboardView()
                    }
                }
                .background(Color.white)
        }
        .environmentObject(homeRouter)
        .background(Color.white)
    }
}

/// 홈 진입을 위한 “안전판”
private struct HomeEntryView: View {
    var body: some View {
        ZStack {
            HomeView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)

        }
    }
}
