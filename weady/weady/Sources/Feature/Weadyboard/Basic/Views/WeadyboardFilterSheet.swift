//
//  WeadyboardFilterSheet.swift
//  weady
//
//  Created by 엄민서 on 7/24/25.
//

import SwiftUI

struct WeadyboardFilterSheet: View {
    @Environment(\.dismiss) private var dismiss

    let onApply: (BoardFilterCriteria) -> Void
    var initialCriteria: BoardFilterCriteria = .init()

    @StateObject private var tagVM = TagViewModel()

    @State private var temperature: Double = 10

    private func weatherIconName(for tagId: Int) -> String {
        WeatherTag.imageName(for: tagId)
    }

    init(
        onApply: @escaping (BoardFilterCriteria) -> Void,
        initialCriteria: BoardFilterCriteria = .init()
    ) {
        self.onApply = onApply
        self.initialCriteria = initialCriteria
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            header

            if tagVM.isLoading {
                ProgressView()
                    .padding(.top, 24)
                Spacer()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24 * .deviceScale) {

                        // MARK: - 계절
                        sectionTitle("계절")
                        HStack(spacing: 8 * .deviceScale) {
                            ForEach(tagVM.seasons, id: \.id) { tag in
                                FilterTag(
                                    text: tag.name,
                                    isSelected: tagVM.selectedSeasonIds.contains(tag.id),
                                    selectedBackground: .black100,
                                    selectedTextColor: .white100,
                                    unselectedBackground: .white400,
                                    unselectedTextColor: .black100
                                ) {
                                    if tagVM.selectedSeasonIds.contains(tag.id) {
                                        tagVM.selectedSeasonIds.remove(tag.id)
                                    } else {
                                        tagVM.selectedSeasonIds.insert(tag.id)
                                    }
                                }
                            }
                            .padding(.leading, 7 * .deviceScale)
                        }

                        // MARK: - 기온
                        sectionTitle("기온")
                        VStack(spacing: 8 * .deviceScale) {
                            Text(tagVM.temperatureRangeText(for: temperature))
                                .fontName(.metaSemibold12)
                                .foregroundColor(.black100)

                            Text(tagVM.temperatureStatusText(for: temperature))
                                .fontName(.metaSemibold12)
                                .foregroundColor(.black100)
                        }
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)

                        GradientSliderView(value: $temperature, range: -6...31)
                            .padding(.horizontal, 8 * .deviceScale)

                        // MARK: - 날씨
                        sectionTitle("날씨")

                        let weatherColumns: [GridItem] = Array(
                            repeating: GridItem(.flexible(), spacing: 12 * .deviceScale),
                            count: 3
                        )
                        LazyVGrid(columns: weatherColumns, spacing: 15 * .deviceScale) {
                            ForEach(tagVM.weathers, id: \.id) { tag in
                                FilterIconTag(
                                    label: tag.name,
                                    imageName: weatherIconName(for: tag.id),
                                    isSelected: tagVM.selectedWeatherIds.contains(tag.id),
                                    selectedBackground: .black100,
                                    selectedTextColor: .white100,
                                    unselectedBackground: .white400,
                                    unselectedTextColor: .black100
                                ) {
                                    if tagVM.selectedWeatherIds.contains(tag.id) {
                                        tagVM.selectedWeatherIds.remove(tag.id)
                                    } else {
                                        tagVM.selectedWeatherIds.insert(tag.id)
                                    }
                                }
                            }
                        }
                        .padding(.trailing, 20 * .deviceScale)
                    }
                    .padding(20 * .deviceScale)
                }
            }
        }
        .background(Color.white)
        .presentationDetents([.height(567 * .deviceScale)])
        .presentationDragIndicator(.hidden)
        .onAppear {
            tagVM.loadAll(initialCriteria: initialCriteria)

            if let tId = initialCriteria.temperatureTagId {
                temperature = tagVM.sliderValue(from: tId)
            } else {
                temperature = 10
            }
        }
    }

    private var header: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .foregroundColor(.black)
                    .frame(width: 9.5 * .deviceScale, height: 17 * .deviceScale)
            }
            Spacer()
            Text("필터")
                .fontName(.bodySemibold16)
            Spacer()
            Button {
                let criteria = tagVM.buildCriteria(from: temperature)
                onApply(criteria)
                dismiss()
            } label: {
                Text("완료")
                    .fontName(.captionMedium14)
                    .foregroundColor(.black)
            }
        }
        .padding(.horizontal, 16 * .deviceScale)
        .padding(.vertical, 12 * .deviceScale)
    }

    private func sectionTitle(_ title: String) -> some View {
        VStack(alignment: .leading, spacing: 12 * .deviceScale) {
            Text(title)
                .fontName(.metaSemibold12)
                .foregroundColor(.black100)
                .padding(.leading, 10 * .deviceScale)

            Rectangle()
                .fill(Color.gray600)
                .frame(height: 1)
        }
    }
}
