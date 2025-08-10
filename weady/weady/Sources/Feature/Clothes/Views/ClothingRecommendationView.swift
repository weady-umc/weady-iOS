//
//  ClothingRecommendationView.swift
//  weady
//
//  Created by 김영택 on 8/8/25.
//

import SwiftUI
import Combine
import Charts


struct ClothingRecommendationView: View {
    @StateObject private var vm: ClothingRecommendationViewModel
    private enum Route: Hashable { case weadyboard }
    
    private enum HelpStep: Hashable { case intro, details }
    @State private var showHelp = false //HelpGuideCardView
    @State private var helpStep: HelpStep = .intro //HelpGuideCardView 1,2
    
    let same = Date()
    
    // 실제 앱에서 토큰으로 초기화
    init(token: String) {
        _vm = StateObject(wrappedValue: ClothingRecommendationViewModel(token: token))
    }
    
    // Preview에서 더미 VM 주입
    init(vm: ClothingRecommendationViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        NavigationStack {
            ZStack{
                Image("backgroundImage")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 0) {
                    // 주소
                    HStack {
                        Image("mapIcon")
                            .resizable()
                            .frame(width: 12, height: 17)
                        Text(vm.addressText)
                            .fontName(.bodySemibold16)
                            .foregroundStyle(.appwhite100)
                        Image("downIcon")
                            .resizable()
                            .frame(width: 10, height: 4)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 41)
                    .padding(.bottom, 1)
                    
                    // 추천 옷 이미지
#if DEBUG
                    // Preview에서는 네트워크 호출 없이 바로 에셋 이미지를 보여주기
                    Image("thinJacket")
                        .resizable()
                        .frame(width: 191, height: 173)
                        .frame(maxWidth: .infinity, alignment: .center)
#else
                    AsyncImage(url: vm.clothingImageUrl) { image in
                        image.resizable().aspectRatio(contentMode: .fit)
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 191, height: 173)
                    .frame(maxWidth: .infinity, alignment: .center)
#endif
                    
                    // 추천 문구
                    VStack(){
                        HStack(spacing: 0){
                            Text("오늘은 ")
                                .fontName(.titleMedium24)
                            Text("\(vm.clothingName)")
                                .fontName(.titleBold24)
                            Text("이")
                                .fontName(.titleMedium24)
                        }
                        Text("딱 좋은 날이에요.")
                            .fontName(.titleMedium24)
                    }
                    .padding(.top, 1)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundStyle(.appwhite100)
                    
                    // 체감온도
                    HStack(spacing: 9) {
                        Image("thermometer")
                            .resizable()
                            .frame(width: 8, height: 16)
                        Text("체감 \(vm.feelTemp)°")
                            .fontName(.captionRegular14)
                            .foregroundStyle(.appwhite100)
                    }
                    .padding(.horizontal, 165)
                    .padding(.top, 14)
                    
                    Spacer().frame(height: 21)
                    
                    // 기온 차트
                    TemperatureChartView(chartItems: vm.chartItems)
                        .frame(width: 337, height: 138)
                        .padding(.top, 21)
                        .padding(.horizontal, 20)
                    
                    // 체감온도 기준
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            helpStep = .intro   // 첫 화면부터 시작
                            showHelp = true     // 오버레이 열기
                        }
                    } label: {
                        HStack(spacing: 3) {
                            Image("helpIcon")
                                .resizable()
                                .frame(width: 12, height: 12)
                            Text("체감온도 기준")
                                .fontName(.metaMedium8)
                                .foregroundColor(.appwhite100)
                        }
                    }
                    .padding(.leading, 312)
                    .padding(.top, 13)
                    
                    NavigationLink {
                        WeadyboardView()
                    } label: {
                        NavigationRowLabel(
                            title: "다른 사람들은 어떻게 입었는지 보러가기",
                            images: ["howPic1","howPic2","howPic3"]
                        )
                        .contentShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 13)
                    .padding(.bottom, 19)
                }
                if showHelp {
                    ZStack {
                        Color.black.opacity(0.45)
                            .ignoresSafeArea()
                            .onTapGesture { withAnimation(.easeOut(duration: 0.2)) { showHelp = false } }

                        if helpStep == .intro {
                            HelpGuideCardView(
                                onClose: { withAnimation(.easeOut(duration: 0.2)) { showHelp = false } },
                                onNext:  { withAnimation(.easeInOut) { helpStep = .details } }
                            )
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                        } else {
                            HelpGuideCardView2(
                                onClose: { withAnimation(.easeOut(duration: 0.2)) { showHelp = false } },
                                onBack:  { withAnimation(.easeInOut) { helpStep = .intro } }
                            )
                            .transition(.move(edge: .leading).combined(with: .opacity))
                        }
                    }
                    .zIndex(3)
                }
            }
        }
    }
}

struct NavigationRowLabel: View {
    let title: String
    let images: [String]
    var body: some View {
        HStack(spacing: 0) {
            Text(title)
                .fontName(.captionMedium14)
                .foregroundColor(.black100)
                .padding(.trailing, 15)
            OverlappingThumbnails(images: images, size: 28, overlap: 14)
                .padding(.trailing, 22)
            Image("rightIcon")
                .resizable()
                .frame(width: 23, height: 23)
        }
        .padding(.leading, 30)
        .padding(.trailing, 10)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10).fill(Color.appwhite100)
        )
    }
}

// 3장까지 겹치는 썸네일
struct OverlappingThumbnails: View {
    let images: [String]
    var size: CGFloat = 28
    let aspect: CGFloat = 21.0/28.0
    var overlap: CGFloat = 14     // 겹치는 정도
    var centerLift: CGFloat = 2   // 가운데 이미지 위로 올리는 정도
    var sideDrop: CGFloat  = 4    // 양쪽 이미지 아래로 내리는 정도

    var body: some View {
        let capped = Array(images.prefix(3))
        let mid = capped.count / 2

        HStack(spacing: -overlap) {
            ForEach(capped.indices, id: \.self) { i in
                Image(capped[i])
                    .resizable()
                    .scaledToFill()
                    .frame(width: size * aspect, height: size)
                    .rotationEffect(.degrees(i == mid ? 0 : (i < mid ? -6 : 6)))
                    .offset(y: i == mid ? centerLift : sideDrop)
                    .zIndex(Double(i))
            }
        }
        .frame(height: size)
        .offset(y: -((sideDrop + centerLift + sideDrop) / 3))
    }
}

// MARK: - Preview & Mock
extension ClothingRecommendationViewModel {
    static var preview: ClothingRecommendationViewModel {
        let vm = ClothingRecommendationViewModel(token: "")
        vm.addressText = "서초구 양재1동"
        vm.feelTemp = 19
        vm.clothingName = "얇은 겉옷"
        vm.clothingImageUrl = Bundle.main.url(forResource: "shirt_icon", withExtension: "png")
        vm.chartItems = (8...21).map { hour in
            // 샘플 온도는 자유롭게
            let samples = [24,26,27,29,30,31,32,31,31,30,28,26,25,24]
            let t = samples[hour - 8]
            return ChartItem(time: hour, feelTmp: Double(t),
                             clothing: ClothingItem(name: "샘플", imageUrl: "thinJacket"))
        }
        return vm
    }
}

struct ClothingRecommendationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {ClothingRecommendationView(vm: .preview)}
    }
}

