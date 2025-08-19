import SwiftUI
import KeychainSwift

/// Curation 첫 화면
struct CurationView: View {
//MARK: - 프로퍼티
    @StateObject private var vm = CurationViewModel()
    @Environment(HomeRouter.self) private var router
  
    
    
    
//MARK: -뷰 바디
    var body: some View {

        
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                // 1) 상단 텍스트: [가변] + [고정]
                HeaderView(leading: vm.headerText.leading,
                           trailing: vm.headerText.trailing,
                           accent: vm.accentColor)
                    .padding(.leading, 16)

                // 상태/에러 안내 배너 (404, 500 등)
                if let msg = vm.noticeText, !msg.isEmpty {
                    Text(msg)
                       
                        .fontName(.captionSemibold14)
                        .foregroundStyle(.secondary)
                }

                // 2) 장소 원형 칩 스크롤
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(vm.tags) { tag in
                            TagChip(tag: tag, isSelected: tag.id == vm.selectedTag.id && tag.kind == vm.selectedTag.kind, accent: vm.accentColor)
                                .onTapGesture {
                                    Task { await vm.select(tag: tag) }
                                }
                        }
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 16)
                }

                // 3) 카드 리스트 (4개)
                if vm.cards.isEmpty {
                    // 데이터가 없을 때(예: 404) 혹은 아직 로딩 직후
                    VStack(alignment: .leading, spacing: 8) {
                        // noticeText가 있으면 그걸, 없으면 기본 안내 문구
                        Text(vm.noticeText?.isEmpty == false ? (vm.noticeText ?? "") : "")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(.secondary)
                      
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    // 카드 리스트가 있는 경우 CardRow를 순서대로 나열.!
                    VStack(spacing: 10) {
                        ForEach(vm.cards) { card in
                            CardRow(title: card.title, imageURL: card.thumbnailURL)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    router.push(.curationdetail(curationId: Int64(card.id)))
                                }
                                .padding(.horizontal, 16)
                            
                            
                        }
                    }
                    .padding(.top, 8)
                }
            }
            .padding(.leading, 12)
            .padding(.trailing, 12)
        }
        .task { await vm.boot() }
    }
}

// MARK: - 날씨 안내 문구
private struct HeaderView: View {
    let leading: String
    let trailing: String
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 0) {
                Text(leading)
                    .fontName(.headingBold20)
                    .foregroundColor(accent) // 계절별 컬러칩 적용
                Text("에는")
                    .fontName(.headingMedium20)
                    .foregroundColor(.primary)
            }
            Text(trailing)
                .fontName(.headingMedium20)
        }
    }
}

// MARK: - 장소 칩 (원형, 띄어쓰기 줄바꿈, 선택 시 테두리 색상 변경)
private struct TagChip: View {
    let tag: LocationTag
    let isSelected: Bool
    let accent: Color

    var body: some View {
        let words = tag.name.split(separator: " ").map(String.init)
        VStack(spacing: 2) {
            if tag.kind == .nearby {
                Image(systemName: "location.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.black)
            }
            ForEach(words, id: \.self) { word in
                Text(word)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.black)
            }
        }
        .frame(width: 63, height: 63)
        .contentShape(Circle())
        .background(
            ZStack {
                Circle().fill(Color.white)
                Circle().stroke(
                    isSelected ? accent : Color.black.opacity(0.85),
                    lineWidth: isSelected ? 5 : 1.5
                )
            }
        )
        .frame(width: 63, height: 63)
        .clipShape(Circle())
    }
}

// MARK: - 큐레이션 썸네일(backgroundImgUrl)
private struct CardRow: View {
    let title: String
    let imageURL: URL?

    var body: some View {
        AsyncImage(url: imageURL) { phase in
            switch phase {
            case .success(let image):
                image
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFill()
            default:
                Color.clear
            }
        }
        .frame(width: 350, height: 100)
        .clipped()
        .frame(maxWidth: .infinity, alignment: .center)
        .clipShape(RoundedRectangle(cornerRadius: 4))
       
    }
}


#Preview("CurationView") {
    CurationView()
        .environment(HomeRouter()) //  Observation 스타일 프리뷰 주입
}
