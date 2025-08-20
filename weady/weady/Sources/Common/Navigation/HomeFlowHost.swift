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
@Observable
final class HomeRouter {
    // MARK: Properties
    var path = NavigationPath()
    
    // MARK: Navigation Actions
    func push(_ route: HomeRoute) { path.append(route) }
    func pop() { if !path.isEmpty { path.removeLast() } }
    func reset() { path = NavigationPath() }
}

// MARK: - HomeFlowHost
/// 홈 플로우 전용 NavigationStack
/// 홈 관련 화면 전환은 여기에서 관리
struct HomeFlowHost: View {
    // MARK: Properties
    @State private var router = HomeRouter()
    @Binding var isTabBarHidden: Bool

    // MARK: Body
    var body: some View {
        @Bindable var router = router
        NavigationStack(path: $router.path) {
            HomeView()
            
                .navigationDestination(for: HomeRoute.self) { route in
                    switch route {
                    case .home:
                        HomeView()
                    case .weatherhome:
                        WeatherHomeView()
                    case .weatheradd(let place, let weather):
                        WeatherLocationAddView(
                            viewModel: WeatherLocationAddViewModel(),
                            locationViewModel: WeatherLocationViewModel(),
                            selectedPlace: .constant(place),
                            onComplete: {
                                router.reset()
                                router.push(.weatherlocation)
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
        }
//         필요 시 하위 뷰에서 @Environment(HomeRouter.self)로 직접 push/pop 가능
        .environment(router)
    }
}
