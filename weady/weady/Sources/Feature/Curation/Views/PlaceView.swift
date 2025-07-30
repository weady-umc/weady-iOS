// 유니 홈화면에 맞게 뷰 이름 설정 -> PlaceView.swift
import SwiftUI


struct PlaceView: View {
    // TODO: - 날씨 태그 색상/문구는 이후 enum 처리 예정
    let locationTags = ["내주변", "강남 서초", "잠실 송파", "여의도 영등포", "건대 성수", "광화문 종로", "홍대 합정", "용산 이태원", "인천 송도" , "수원 광교", "성남 분당"]
    // TODO: - 더미 데이터는 이후 API 또는 기본 장소 몇개 추가 생성시 바뀔 예정
    let dummyCurationData: [String: [String]] = [
        "내주변": ["place1", "place2", "place3", "place4"],
        "강남 서초": ["place2", "place1", "place4", "place3"],
        "잠실 송파": ["place3", "place2", "place1", "place4"],
        "여의도 영등포": ["place4", "place3", "place2", "place1"],
        "건대 성수": ["place1", "place4", "place3", "place2"],
        "광화문 종로": ["place2", "place1", "place4", "place3"],
        "홍대 합정": ["place3", "place2", "place1", "place4"],
        "용산 이태원": ["place4", "place3", "place2", "place1"],
        "인천 송도": ["place1", "place4", "place3", "place2"],
        "수원 광교": ["place2", "place1", "place4", "place3"],
        "성남 분당": ["place3", "place2", "place1", "place4"]
        // 나머지 태그들도 원한다면 이후 추가
    ]
    
    @State private var selectedTag: String = "내주변"
    @State private var currentWeather: SkyStatus = .CLEAR

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                // 상단 텍스트
                Group {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing : 0) {
                            // TODO: - 날씨에 맞는 태그 텍스트 수정 예정.
                            Text(currentWeather.descriptionText)
                                .foregroundColor(SkyStatus.CLEAR.fontColor)
                                .fontName(.headingBold20)
                            
                            Text("에는,")
                                .fontName(.headingBold20)
                        }
                        Text("이런 코스들을 추천해 드려요")
                            .fontName(.headingBold20)
                    }
                }
                .padding(.horizontal, 16)

                LocationTagScrollView(locationTags: locationTags, selectedTag: $selectedTag)

                ScrollView {
                    let dummyImageNames = dummyCurationData[selectedTag] ?? []
                    let dummyIDs = Array(0..<dummyImageNames.count).map { "\($0)" }
                    CurationCardListView(selectedTag: selectedTag, imageNames: dummyImageNames, cardIDs: dummyIDs)
                }
            }
            .padding(.top, 20)
        }
    }
}

struct LocationTagScrollView: View {
    let locationTags: [String]
    @Binding var selectedTag: String

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(locationTags, id: \.self) { tag in
                    let words = tag.split(separator: " ").map(String.init)
                    VStack(spacing: 2) {
                        if tag == "내주변" {
                            Image(systemName: "location.fill")
                                .font(.custom("Meta-Semibold", size: 12))
                                .foregroundStyle(.black)
                        }
                        ForEach(words, id: \.self) { word in
                            Text(word)
                                .fontName(.metaSemibold12)
                                .foregroundStyle(.black)
                        }
                    }
                    .frame(width: 63, height: 63)
                    .background(
                        ZStack {
                            Circle()
                                .fill(Color.white)
                            Circle()
                                .stroke(selectedTag == tag ? Color.yellow : Color(red: 0.07, green: 0.07, blue: 0.07), lineWidth: 1.5)
                        }
                    )
                    .frame(width: 63, height: 63)
                    .clipShape(Circle())
                    .onTapGesture {
                        selectedTag = tag
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

struct CurationCardListView: View {
    let selectedTag: String
    let imageNames: [String]
    let cardIDs: [String]

    var body: some View {
        VStack(spacing: 12) {
            ForEach(Array(zip(imageNames, cardIDs)), id: \.1) { (imageName, cardID) in
                NavigationLink(destination: DetailCurationView(cardID: cardID)) {
                    ZStack(alignment: .bottomLeading) {
                        Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 335, height: 100)
                            .clipped()
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 16)
            }
        }
        .padding(.top, 8)
    }
}






enum SkyStatus {
    case CLEAR, PARTLY_CLOUDY, CLOUDY, RAIN, SNOW

    var fontColor: Color {
        switch self {
        case .CLEAR:
            return Color(red: 0.92, green: 0.59, blue: 0.59)
        case .PARTLY_CLOUDY:
            return .secondary
        case .CLOUDY:
            return .gray
        case .RAIN:
            return .blue
        case .SNOW:
            return .mint
        }
    }

    var descriptionText: String {
        switch self {
        case .CLEAR:
            return "맑은 하늘"
        case .PARTLY_CLOUDY:
            return "구름 조금"
        case .CLOUDY:
            return "흐린 날씨"
        case .RAIN:
            return "비 오는 날"
        case .SNOW:
            return "눈 오는 날"
        }
    }
}

enum Season {
    case spring, summer, autumn, winter
}

extension Season {
    static func currentSeason(date: Date = Date()) -> Season {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)

        switch month {
        case 3...5:
            return .spring
        case 6...8:
            return .summer
        case 9...11:
            return .autumn
        default:
            return .winter // 12, 1, 2
        }
    }
}



#Preview {
    PlaceView()
}
