
//
//  ClothingRecommendationView.swift
//  weady
//
//  Created by 김영택 on 8/8/25.
//

import SwiftUI
import Combine
import Observation

// MARK: - ClothingRecommendationView

struct ClothingRecommendationView: View {
    // ViewModel
    @StateObject private var vm: ClothingRecommendationViewModel

    // Routing / Tabs
    @Environment(\.homeRouter) private var router
    @Environment(AppTabController.self) private var tabController

    // Top segment (.first = 날씨, .second = 옷차림, .third = 장소)
    @State private var selectedSegment: WeatherHomeModel = .second

    // Help Overlay
    enum HelpStep: Hashable { case intro, details }
    @State private var showHelp = false
    @State private var helpStep: HelpStep = .intro

    // Initializers (기존 시그니처 유지)
    init() { _vm = StateObject(wrappedValue: ClothingRecommendationViewModel()) }
    init(token: String) { _vm = StateObject(wrappedValue: ClothingRecommendationViewModel()) }
    init(vm: ClothingRecommendationViewModel) { _vm = StateObject(wrappedValue: vm) }

    var body: some View {
        ZStack(alignment: .top) {
            // Background
            Image("backgroundImage")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(alignment: .center, spacing: 0) {
                // 1) 주소 행
                AddressRow(
                    text: vm.addressText,
                    onTapChevron: { router.push(HomeRoute.weatherlocation) }
                )
                .padding(.top, 41)

                // 2) 추천 이미지
                HeroImage(imageUrl: vm.clothingImageUrl)
                    .padding(.top, -10)

                // 3) 추천 문구
                CopyBlock(title: vm.clothingName, particle: vm.subjectParticle)
                    .padding(.top, -5)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundStyle(.appwhite100)

                // 4) 체감온도
                FeelTempRow(feelTemp: vm.feelTemp)
                    .padding(.top, 15)

                Spacer().frame(height: 23)

                // 5) 기온 차트 섹션
                TemperatureChartSection(chartItems: vm.chartItems)

                // 6) 체감온도 기준 (도움말)
                HelpButton {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        helpStep = .intro
                        showHelp = true
                    }
                }
                .padding(.top, 13)

                // 7) Weadyboard CTA (탭 전환)
                WeadyboardCTA(
                    title: "다른 사람들은 어떻게 입었는지 보러가기",
                    images: ["howPic1","howPic2","howPic3"],
                    onTap: { tabController.switchTo(.weadyboard) }
                )
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 13)
                .padding(.bottom, 19)
            }

            // Help Overlay (외부 컴포넌트가 프로젝트에 있다고 가정)
            HelpOverlay(
                isPresented: $showHelp,
                step: $helpStep,
                onClose: { withAnimation(.easeOut(duration: 0.2)) { showHelp = false } }
            )
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .safeAreaInset(edge: .top) {
            // 화면 자체에서 올리는 상단 세그먼트 바 (날씨 | 옷차림 | 장소)
            TopSegmentBar(
                selected: selectedSegment,
                onSelect: { seg in
                    withAnimation { selectedSegment = seg }
                    let route = route(for: seg)          // ① 라우트 계산
                    router.path = NavigationPath()       // ② 필요하면 스택 초기화
                    router.push(route)                   // ③ 결과 HomeRoute를 push
                }
            )
        }
        .onAppear { selectedSegment = .second }
    }
}

// 세그먼트 → 라우트 매핑
private func route(for seg: WeatherHomeModel) -> HomeRoute {
    switch seg {
    case .first:  return .weatherhome(initial: .first)
    case .second: return .clothes
    case .third:  return .curation   // 정책에 따라 .curation으로 교체 가능
    }
}

// MARK: - Private Subviews (same file)

private struct AddressRow: View {
    let text: String
    let onTapChevron: () -> Void

    var body: some View {
        HStack(spacing: 3) {
            Image("mapIcon")
                .resizable()
                .frame(width: 12, height: 17)

            Text(text)
                .fontName(.bodySemibold16)
                .foregroundStyle(.appwhite100)
                .lineLimit(1)
                .truncationMode(.tail)
                .layoutPriority(1)

            Button(action: onTapChevron) {
                Image("clothesDownIcon")
                    .resizable()
                    .frame(width: 10, height: 4)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .frame(height: 24)
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

private struct HeroImage: View {
    let imageUrl: URL?

    var body: some View {
#if DEBUG
        Image("teeShirt")
            .resizable()
            .frame(width: 195, height: 195)
            .frame(maxWidth: .infinity, alignment: .center)
#else
        Group {
            if let url = imageUrl {
                AsyncImage(url: url) { image in
                    image.resizable().aspectRatio(contentMode: .fit)
                } placeholder: { ProgressView() }
            } else {
                Color.clear
            }
        }
        .frame(width: 195, height: 195)
        .frame(maxWidth: .infinity, alignment: .center)
#endif
    }
}

private struct CopyBlock: View {
    let title: String
    let particle: String

    var body: some View {
        VStack {
            HStack(spacing: 0) {
                Text("오늘은 ").fontName(.titleMedium24)
                Text(title).fontName(.titleBold24)
                Text(particle).fontName(.titleMedium24)
            }
            Text("딱 좋은 날이에요.")
                .fontName(.titleMedium24)
        }
    }
}

private struct FeelTempRow: View {
    let feelTemp: Int

    var body: some View {
        HStack(spacing: 9) {
            Image("thermometer")
                .resizable()
                .frame(width: 8, height: 16)
            Text("체감 \(feelTemp)°")
                .fontName(.captionRegular14)
                .foregroundStyle(.appwhite100)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

private struct TemperatureChartSection: View {
    let chartItems: [ChartItem]
    var body: some View {
        TemperatureChartView(chartItems: chartItems)
            .frame(width: 310, height: 133)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.trailing, 20)
    }
}

private struct HelpButton: View {
    let onTap: () -> Void
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 3) {
                Image("helpIcon")
                    .resizable()
                    .frame(width: 12, height: 12)
                Text("체감온도 기준")
                    .fontName(.metaMedium8)
                    .foregroundColor(.appwhite100)
            }
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.horizontal, 20)
    }
}

private struct TopSegmentBar: View {
    let selected: WeatherHomeModel
    let onSelect: (WeatherHomeModel) -> Void

    var body: some View {
        HStack(spacing: 0) {
            // WeatherHomeModel이 Identifiable이 아닐 수 있으니 안전하게 self 사용
            ForEach(WeatherHomeModel.allCases, id: \.self) { segment in
                Button { onSelect(segment) } label: {
                    VStack(spacing: 8) {
                        Text(segment.title)
                            .fontName(.headingSemibold20)
                            .foregroundStyle(selected == segment ? Color.gray100 : Color.gray800)

                        if selected == segment {
                            Rectangle().fill(Color.gray100).frame(width: 59, height: 2)
                        } else {
                            Rectangle().fill(Color.gray800).frame(width: 59, height: 2)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.top, 5)
        .padding(.bottom, 0)
        .background(Color.white.ignoresSafeArea(edges: .top))
        .overlay(Divider(), alignment: .bottom)
        .transaction { $0.disablesAnimations = true }
    }
}

// MARK: - EnvironmentKey for HomeRouter (키패스 기반 주입)

private struct HomeRouterKey: EnvironmentKey {
    static let defaultValue: HomeRouter = HomeRouter()
}

extension EnvironmentValues {
    var homeRouter: HomeRouter {
        get { self[HomeRouterKey.self] }
        set { self[HomeRouterKey.self] = newValue }
    }
}

// MARK: - Preview

#if DEBUG
struct ClothingRecommendationView_Previews: PreviewProvider {
    static var previews: some View {
        let router = HomeRouter()
        let tabs = AppTabController()

        NavigationStack {
            // ① 기본 생성자 사용
            ClothingRecommendationView()
            // 또는 ② 명시적으로 생성
            // ClothingRecommendationView(vm: ClothingRecommendationViewModel())
        }
        .environment(\.homeRouter, router) // 커스텀 키패스 주입
        .environment(tabs)                 // AppTabController typed env
    }
}
#endif
