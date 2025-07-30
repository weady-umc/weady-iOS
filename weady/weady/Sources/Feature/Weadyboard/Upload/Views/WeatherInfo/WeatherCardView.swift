import SwiftUI
import Observation

struct WeatherCardView: View {
    @Bindable var viewModel: WeatherViewModel          // ✅ ViewModel 직접 주입
    var background: Color = .gray100                   // 스샷처럼 짙은 회색

    private var model: WeatherModel { viewModel.current }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            // 계절
            if let season = model.selectedSeason, !season.isEmpty {
                Text(season)
                    .font(.title3).fontWeight(.semibold)
                    .foregroundColor(.white100)
            }

            // 기온 범위(밴드 라벨 사용)
            Text(viewModel.bandLabel(for: model.temperatureBandIndex))
                .font(.title3).fontWeight(.semibold)
                .foregroundColor(.white100)

            // 아이콘 + 날씨 라벨
            HStack(spacing: 12) {
                let tag = viewModel.tag(for: model.selectedWeather)

                Image(tag?.iconName ?? "cloud")
                    .renderingMode(.template)     // 템플릿 에셋이면 흰색 적용
                    .foregroundColor(.white100)
                    .frame(width: 28, height: 20)
                    .aspectRatio(contentMode: .fit)

                Text(tag?.label ?? "-")
                    .font(.title3).fontWeight(.semibold)
                    .foregroundColor(.white100)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(background)
        )
    }
}
