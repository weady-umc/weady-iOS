//import SwiftUI
//
///// PlaceView의 UI/폰트/레이아웃을 그대로 유지하면서, 카테고리 ID 매핑을 부여한 CurationView
//struct CurationView: View {
//    // 고정 태그(원형 8개): "내주변" + 7개 지역
//    private let locationTags: [String] = [
//        "내주변",
//        "홍대 합정",
//        "용산 이태원",
//        "광화문 종로",
//        "강남 서초",
//        "잠실 송파",
//        "여의도 영등포",
//        "건대 상수"
//    ]
//
//    /// 서버의 카테고리 ID 매핑
//    /// "홍대 합정": 1, "용산 이태원": 2, "광화문 종로": 3, "강남 서초": 4,
//    /// "잠실 송파": 5, "여의도 영등포": 6, "건대 상수": 7
//    private let categoryIdForTag: [String: Int] = [
//        "홍대 합정": 1,
//        "용산 이태원": 2,
//        "광화문 종로": 3,
//        "강남 서초": 4,
//        "잠실 송파": 5,
//        "여의도 영등포": 6,
//        "건대 상수": 7
//    ]
//
//    // 더미 데이터 (PlaceView와 동일 구조: 이후 API 연동 시 대체)
//    private let CurationData: [String: [String]] = [
//        "내주변": ["place1", "place2", "place3", "place4"],
//        "홍대 합정": ["place2", "place1", "place4", "place3"],
//        "용산 이태원": ["place3", "place2", "place1", "place4"],
//        "광화문 종로": ["place4", "place3", "place2", "place1"],
//        "강남 서초": ["place1", "place4", "place3", "place2"],
//        "잠실 송파": ["place2", "place1", "place4", "place3"],
//        "여의도 영등포": ["place3", "place2", "place1", "place4"],
//        "건대 상수": ["place4", "place3", "place2", "place1"]
//    ]
//
//    @State private var selectedTag: String = "내주변"
//    @State private var currentWeather: SkyStatus = .CLEAR
//
//    // 선택된 태그에 해당하는 서버 카테고리 ID (내주변은 nil)
//    private var selectedCategoryId: Int? { categoryIdForTag[selectedTag] }
//
//    var body: some View {
//        NavigationStack {
//            VStack(alignment: .leading, spacing: 16) {
//                // 상단 텍스트 (PlaceView와 동일 폰트/색상 규칙)
//                Group {
//                    VStack(alignment: .leading, spacing: 2) {
//                        HStack(spacing: 0) {
//                            Text(currentWeather.descriptionText)
//                                .foregroundColor(SkyStatus.CLEAR.fontColor)
//                                .fontName(.headingBold20)
//                            Text("에는,")
//                                .fontName(.headingBold20)
//                        }
//                        Text("이런 코스들을 추천해 드려요")
//                            .fontName(.headingBold20)
//                    }
//                }
//                .padding(.horizontal, 16)
//
//                // 원형 장소 태그 스크롤 (PlaceView와 동일 UI – 줄바꿈 처리 포함)
//                CurationLocationTagScrollView(
//                    locationTags: locationTags,
//                    selectedTag: $selectedTag
//                )
//
//                // 카드 리스트 (PlaceView와 동일 – 더미 이미지 사용)
//                ScrollView {
//                    let names = dummyCurationData[selectedTag] ?? []
//                    let ids = Array(0..<names.count).map { "\($0)" }
//                    CurationCardListView(selectedTag: selectedTag, imageNames: names, cardIDs: ids)
//                }
//            }
//            .padding(.top, 20)
//        }
//    }
//}
//
///// 원형 장소 태그(공백 기준 줄바꿈) – PlaceView와 동일한 스타일
//struct CurationLocationTagScrollView: View {
//    let locationTags: [String]
//    @Binding var selectedTag: String
//
//    var body: some View {
//        ScrollView(.horizontal, showsIndicators: false) {
//            HStack(spacing: 12) {
//                ForEach(locationTags, id: \.self) { tag in
//                    let words = tag.split(separator: " ").map(String.init)
//                    VStack(spacing: 2) {
//                        if tag == "내주변" {
//                            Image(systemName: "location.fill")
//                                .font(.custom("Meta-Semibold", size: 12))
//                                .foregroundStyle(.black)
//                        }
//                        ForEach(words, id: \.self) { word in
//                            Text(word)
//                                .fontName(.metaSemibold12)
//                                .foregroundStyle(.black)
//                        }
//                    }
//                    .frame(width: 63, height: 63)
//                    .background(
//                        ZStack {
//                            Circle().fill(Color.white)
//                            Circle().stroke(selectedTag == tag ? Color.yellow : Color(red: 0.07, green: 0.07, blue: 0.07), lineWidth: 1.5)
//                        }
//                    )
//                    .frame(width: 63, height: 63)
//                    .clipShape(Circle())
//                    .onTapGesture { selectedTag = tag }
//                }
//            }
//            .padding(.horizontal, 16)
//        }
//    }
//}
//
//// PlaceView와 동일 카드 리스트 뷰 (이미 프로젝트에 존재한다면 중복 정의 제거)
//struct CurationCardListView: View {
//    let selectedTag: String
//    let imageNames: [String]
//    let cardIDs: [String]
//
//    var body: some View {
//        VStack(spacing: 12) {
//            ForEach(Array(zip(imageNames, cardIDs)), id: \.1) { (imageName, cardID) in
//                NavigationLink(destination: DetailCurationView(cardID: cardID)) {
//                    ZStack(alignment: .bottomLeading) {
//                        Image(imageName)
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                            .frame(width: 335, height: 100)
//                            .clipped()
//                            .frame(maxWidth: .infinity, alignment: .center)
//                    }
//                }
//                .buttonStyle(PlainButtonStyle())
//                .padding(.horizontal, 16)
//            }
//        }
//        .padding(.top, 8)
//    }
//}
//
//#Preview("CurationView") {
//    CurationView()
//}
//ㅋ
