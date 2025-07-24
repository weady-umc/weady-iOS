// 유니 홈화면에 맞게 뷰 이름 설정 -> PlaceView.swift
import SwiftUI


struct PlaceView: View {
    // TODO: - 날씨 태그 색상/문구는 이후 enum 처리 예정
    let locationTags = ["내주변", "성수", "광화문 종로", "합정 망원", "홍대 신촌", "명동 을지로", "문래 여의도", "강남 역삼", "잠실 송파" , "이태원 한남"]
    // TODO: - 더미 데이터는 이후 API 또는 기본 장소 몇개 추가 생성시 바뀔 예정
    let dummyCurationData: [String: [String]] = [
        "내주변": ["place1", "place2", "place3", "place4"],
        "성수": ["place2", "place1", "place4", "place3"],
        "광화문 종로": ["place3", "place2", "place1", "place4"],
        "합정 망원": ["place4", "place3", "place2", "place1"],
        "홍대 신촌": ["place1", "place4", "place3", "place2"],
        "명동 을지로": ["place2", "place1", "place4", "place3"],
        "문래 여의도": ["place3", "place2", "place1", "place4"],
        "강남 역삼": ["place4", "place3", "place2", "place1"],
        "잠실 송파": ["place1", "place4", "place3", "place2"],
        "이태원 한남": ["place2", "place1", "place4", "place3"]
        // 나머지 태그들도 원한다면 이후 추가
    ]
    
    @State private var selectedTag: String = "내주변"

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 상단 텍스트
            Group {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing : 0) {
                        // TODO: - 날씨에 맞는 태그 텍스트 수정 예정.
                        Text("살랑살랑 봄 날씨")
                            // TODO: - 컬러칩 기본 세팅 안되어있음
                            .foregroundColor(Color(red: 0.92, green: 0.59, blue: 0.59))
                            .fontName(.headingBold20)
                        
                        Text("에는,")
                          
                            .fontName(.headingBold20)
                    }
                    Text("이런 코스들을 추천해 드려요.")
                        
                        .fontName(.headingBold20)
                }
            }
            .padding(.horizontal, 16)

            LocationTagScrollView(locationTags: locationTags, selectedTag: $selectedTag)

            ScrollView {
                let dummyImageNames = dummyCurationData[selectedTag] ?? []
                CurationCardListView(selectedTag: selectedTag, imageNames: dummyImageNames)
            }
        }
        .padding(.top, 20)
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

    var body: some View {
        VStack(spacing: 12) {
            ForEach(imageNames, id: \.self) { imageName in
                Button(action: {
                    // TODO: - 해당 큐레이션 상세로 이동
                }) {
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

#Preview {
    PlaceView()
}
