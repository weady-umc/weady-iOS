////
////  ClothingRecommendationView.swift
////  weady
////
////  Created by 김영택 on 8/8/25.
////
//
//import SwiftUI
//import Combine
//import Charts
//
//
//struct ClothingRecommendationView: View {
//    @StateObject private var vm: ClothingRecommendationViewModel
//
//    // 실제 앱에서 토큰으로 초기화
//    init(token: String) {
//        _vm = StateObject(wrappedValue: ClothingRecommendationViewModel(token: token))
//    }
//
//    // Preview에서 더미 VM 주입
//    init(vm: ClothingRecommendationViewModel) {
//        _vm = StateObject(wrappedValue: vm)
//    }
//
//    var body: some View {
//        ZStack{
//            Image("backgroundImage")
//                .resizable()
//                .scaledToFill()
//                .ignoresSafeArea()
//            
//            VStack(alignment: .leading, spacing: 0) {
//                // 주소
//                HStack {
//                    Image("mapIcon")
//                        .resizable()
//                        .frame(width: 12, height: 17)
//                    Text(vm.addressText)
//                        .fontName(.bodySemibold16)
//                        .foregroundStyle(.appwhite100)
//                    Image("downIcon")
//                        .resizable()
//                        .frame(width: 10, height: 4)
//                    Spacer()
//                }
//                .padding(.horizontal, 120)
//                .padding(.top, 41)
//                
//                // 추천 옷 이미지
//#if DEBUG
//                // Preview에서는 네트워크 호출 없이 바로 에셋 이미지를 보여주기
//                Image("thinJacket")
//                    .resizable()
//                    .frame(width: 191, height: 173)
//                    .padding(.horizontal, 96)
//#else
//                AsyncImage(url: vm.clothingImageUrl) { image in
//                    image.resizable().aspectRatio(contentMode: .fit)
//                } placeholder: {
//                    ProgressView()
//                }
//                .frame(width: 191, height: 173)
//                .padding(.horizontal, 96)
//#endif
//                
//                // 추천 문구
//                VStack(){
//                    HStack(spacing: 0){
//                        Text("오늘은 ")
//                            .fontName(.titleMedium24)
//                        Text("\(vm.clothingName)")
//                            .fontName(.titleBold24)
//                        Text("이")
//                            .fontName(.titleMedium24)
//                    }
//                    Text("딱 좋은 날이에요.")
//                        .fontName(.titleMedium24)
//                }
//                .padding(.horizontal, 100)
//                .foregroundStyle(.appwhite100)
//                
//                // 체감온도
//                HStack(spacing: 9) {
//                    Image("thermometer")
//                        .resizable()
//                        .frame(width: 8, height: 16)
//                    Text("체감 \(vm.feelTemp)°")
//                        .fontName(.captionRegular14)
//                        .foregroundStyle(.appwhite100)
//                }
//                .padding(.horizontal, 158)
//                .padding(.top, 14)
//                .padding(.bottom, 24)
//                
//                // 기온 차트
//                TemperatureChartView(chartItems: vm.chartItems)
//                    .padding(.top, 21)
//                    .padding(.leading, 28)
//                
//                Button {
//                } label: {
//                    Label("체감온도 기준", image: "helpIcon")
//                        .labelStyle(.titleAndIcon)
//                        .fontName(.metaMedium8)
//                        .foregroundColor(.appwhite100)
//                }
//                .padding(.leading, 288)
//                
//                NavigationLink(destination: WeadyboardView()) {
//                    NavigationButtonRow(
//                        title: "다른 사람들은 어떻게 입었는지 보러가기",
//                        imageName: "howPic",
//                        action: {}
//                    )
//                }
//                .padding(.leading, 20)
//                .padding(.top, 11)
//            }
//        }
//    }
//}
//
//struct NavigationButtonRow: View {
//    let title: String
//    let imageName: String
//    let action: () -> Void
//
//    var body: some View {
//        Button(action: action) {
//            HStack {
//                Text(title)
//                    .fontName(.captionMedium14)
//                    .foregroundColor(.appblack100)
//                    .padding(.leading, 21)
//                Image(imageName)
//                    .resizable()
//                    .scaledToFill()
//                    .frame(width: 21, height: 28)
//                    .clipShape(RoundedRectangle(cornerRadius: 8))
//                    .padding(.leading, 27)
//                Image("rightIcon")
//                    .resizable()
//                    .frame(width: 20, height: 20)
//            }
//            .padding(.vertical,12)
//            .padding(.leading, 27)
//            .padding(.trailing, 5)
//            .background(Color.appwhite100)
//            .cornerRadius(10)
//        }
//    }
//}
//
//// MARK: - Preview & Mock
//extension ClothingRecommendationViewModel {
//    static var preview: ClothingRecommendationViewModel {
//        let vm = ClothingRecommendationViewModel(token: "")
//        vm.addressText = "서초구 양재1동"
//        vm.feelTemp = 19
//        vm.clothingName = "얇은 겉옷"
//        vm.clothingImageUrl = Bundle.main.url(forResource: "shirt_icon", withExtension: "png")
//        vm.chartItems = (6...10).map { hour in
//            ChartItem(time: hour, feelTmp: Double(15 + (hour - 6) * 2),
//                      clothing: ClothingItem(name: "셔츠", imageUrl: "shirt_icon"))
//        }
//        return vm
//    }
//}
//
//struct ClothingRecommendationView_Previews: PreviewProvider {
//    static var previews: some View {
//        ClothingRecommendationView(vm: .preview)
//            .previewDevice("iPhone 13")
//    }
//}
//
