import SwiftUI

// 회색 오버레이(비활성) 모디파이어
extension View {
    func inactiveOverlay(_ inactive: Bool, color: Color = .gray100, opacity: Double = 0.6) -> some View {
        self.overlay(inactive ? color.opacity(opacity) : Color.clear)
            .allowsHitTesting(!inactive)
    }
}

struct WeatherInfoView: View {
    @State private var vm = WeatherViewModel(
//        locationProvider: CoreLocationProvider(),
//        geocodingProvider: CLGeocodingProvider(),
//        weatherProvider: OpenWeatherProvider()
    )
    
    init(vm: WeatherViewModel = WeatherViewModel()) {
            _vm = State(initialValue: vm)
        }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // 모드 전환 (단일 Bool)
                HStack {
                    Text("현재 위치 기준으로 추가하기").foregroundColor(.black100)
                    Spacer()
                    Toggle("", isOn: Binding(get: { !vm.isManual }, set: { vm.isManual = !$0 }))
                        .labelsHidden()
                }
                .padding(.horizontal, 20)

                WeatherCardView(viewModel: vm)
                    .padding(.horizontal, 20)
                    .inactiveOverlay(!vm.isCurrentActive) // 보기만

                HStack {
                    Text("직접 추가하기").foregroundColor(.black100)
                    Spacer()
                    Toggle("", isOn: $vm.isManual).labelsHidden()
                }
                .padding(.horizontal, 20)

                // 현재 위치 폼도 같은 폼을 재사용할 수 있지만, 여기선 카드 + 읽기 전용으로 유지
                // 필요하면 아래처럼 enabled: false 로 같은 폼을 둘 수 있음:
                /*
                WeatherFormView( ... enabled: false, sliderAppearance: .inactiveSolid(.gray300) )
                    .padding(.horizontal, 20)
                    .inactiveOverlay(!vm.isCurrentActive)
                */

                // 직접 추가 폼
                MenualWeatherView(
                    seasonTags: vm.seasonTags,
                    weatherTags: vm.weatherTags,
                    selectedSeason: Binding(
                        get: { vm.manual.selectedSeason },
                        set: { vm.manual.selectedSeason = $0 }
                    ),
                    selectedWeather: Binding(
                        get: { vm.manual.selectedWeather },
                        set: { vm.manual.selectedWeather = $0 }
                    ),
                    temperatureBandIndex: Binding(
                        get: { vm.manual.temperatureBandIndex ?? 0 },
                        set: { vm.setManualBand($0) }
                    )
                )
                .inactiveOverlay(!vm.isManualActive)
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 16)
        }
        .background(Color.white100)
        .navigationTitle("날씨 정보 추가")
        .navigationBarTitleDisplayMode(.inline)
        //.task(id: vm.isCurrentActive) {
            //if vm.isCurrentActive {
                //await vm.refreshCurrentLocationWeather()
            //}
        //}
    }
}

#Preview {
    WeatherInfoView()
}
