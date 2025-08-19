
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
    //@State private var showLocationPicker = false
    //private enum Route: Hashable { case weadyboard }
    @Environment(HomeRouter.self) private var router
    
    enum HelpStep: Hashable { case intro, details }
    @State private var showHelp = false
    @State private var helpStep: HelpStep = .intro
    
    
    
    let same = Date()
    // 기본 init: 내부에서 VM 생성
    init() {
        _vm = StateObject(wrappedValue: ClothingRecommendationViewModel())
    }
    
    // 실제 앱에서 토큰으로 초기화
    init(token: String) {
        _vm = StateObject(wrappedValue: ClothingRecommendationViewModel())
    }
    
    // Preview에서 더미 VM 주입
    init(vm: ClothingRecommendationViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        VStack(spacing:0){
            ZStack{
                Image("backgroundImage")
                    .resizable()
                //.scaledToFill()
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
                        //지역 선택 화면으로 가는 버튼
                        Button {
                            router.push(.weatherlocation)
                        } label: {
                            Image("clothesDownIcon")
                                .resizable()
                                .frame(width: 10, height: 4)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 120)
                    .padding(.top, 41)
                    
                    // 추천 옷 이미지
#if DEBUG
                    // Preview에서는 네트워크 호출 없이 바로 에셋 이미지를 보여주기
                    Image("teeShirt")
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
                        HStack{
                            Text("오늘은 ")
                                .fontName(.titleMedium24)
                            Text(vm.clothingName)
                                .fontName(.titleBold24)
                            Text(vm.subjectParticle)
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
                    
                    WeadyboardCTA(
                        title: "다른 사람들은 어떻게 입었는지 보러가기",
                        images: ["howPic1","howPic2","howPic3"],
                        onTap: { router.push(.weadyboard) }
                    )
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 13)
                    .padding(.bottom, 19)
                }
                
                // 도움말 오버레이
                HelpOverlay(
                    isPresented: $showHelp,
                    step: $helpStep,
                    onClose: { withAnimation(.easeOut(duration: 0.2)) { showHelp = false }}
                )
            }
            
        }
    }
        
}
        

// MARK: - Preview & Mock
extension ClothingRecommendationViewModel {
    static var preview: ClothingRecommendationViewModel {
        let vm = ClothingRecommendationViewModel()
        vm.addressText = "서초구 양재1동"
        vm.feelTemp = 19
        vm.clothingName = "반팔"
        vm.clothingImageUrl = Bundle.main.url(forResource: "shirt_icon", withExtension: "png")
        vm.chartItems = (8...21).map { hour in
            // 샘플 온도는 자유롭게
            let samples = [24,26,27,29,30,31,32,31,31,30,28,26,25,24]
            let t = samples[hour - 8]
            return ChartItem(time: hour, feelTmp: Double(t),
                             clothing: ClothingItem(name: "샘플", imageUrl: "teeShirt"))
        }
        return vm
    }
}

struct ClothingRecommendationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {ClothingRecommendationView(vm: .preview)}
    }
}
