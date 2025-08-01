import SwiftUI
import Observation

struct WeatherCardView: View {
    @Bindable var viewModel: WeatherViewModel

    private var model: WeatherModel { viewModel.weatherModel }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            //MARK: - 계절
            if let season = model.selectedSeason, !season.isEmpty {
                Text(season)
                    .fontName(.metaMedium12)
                    .foregroundColor(.white100)
            }

            //MARK: - 기온
            Text(viewModel.temperatureBand(for: model.temperatureBandIndex))
                .fontName(.metaMedium12)
                .foregroundColor(.white100)

            //MARK: - 날씨
            HStack(spacing: 12) {
                let tag = viewModel.tag(for: model.selectedWeather)

                Image(tag?.iconName ?? "cloud")
                    .renderingMode(.template)
                    .frame(width: 28, height: 20)
                    .aspectRatio(contentMode: .fit)

                Text(tag?.label ?? "-")
                    .fontName(.metaMedium12)
                    .foregroundColor(.white100)
            }
        }
        .padding(.top, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.gray100)
        )
    }
}
