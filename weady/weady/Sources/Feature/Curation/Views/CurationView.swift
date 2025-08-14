import SwiftUI
import KeychainSwift

/// Curation 첫 화면 (PlaceView 레이아웃을 유지하면서 MVVM 바인딩)
struct CurationView: View {
    @StateObject private var vm = CurationViewModel()
    
    

    var body: some View {

        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // 1) 상단 텍스트: [가변] + [고정]
                HeaderView(leading: vm.headerText.leading,
                           trailing: vm.headerText.trailing,
                           accent: vm.accentColor)
                    .padding(.leading, 16)

                // 상태/에러 안내 배너 (404, 500 등)
                if let msg = vm.noticeText, !msg.isEmpty {
                    Text(msg)
                        .font(.system(size: 14, weight: .semibold))
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
                    .padding(.vertical, 8)
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
                        // noticeText가 비어있다면 공간만 유지 (필요 시 스켈레톤 등 교체 가능)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    VStack(spacing: 16) {
                        ForEach(vm.cards) { card in
                            NavigationLink(value: HomeRoute.curationdetail(curationId: Int64(card.id))) {
                                CardRow(title: card.title, imageURL: card.thumbnailURL)
                            }
                            .buttonStyle(.plain)
                            .padding(.top, 2)
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.top, 8)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
        }
        .task { await vm.boot() }
    }
}

// MARK: - Header
private struct HeaderView: View {
    let leading: String
    let trailing: String
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 0) {
                Text(leading)
                    .fontName(.headingBold20)
                    .foregroundColor(accent) // Figma의 포인트색 유사
                Text("에는")
                    .fontName(.headingBold20)
                    .foregroundColor(.primary)
            }
            Text(trailing)
                .fontName(.headingBold20)
        }
    }
}

// MARK: - TagChip (원형, 띄어쓰기 줄바꿈, 선택 시 테두리 강조)
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
                Circle().stroke(isSelected ? accent : Color.black.opacity(0.85), lineWidth: 1.5)
            }
        )
        .frame(width: 63, height: 63)
        .clipShape(Circle())
    }
}

// MARK: - 썸네일
private struct CardRow: View {
    let title: String
    let imageURL: URL?

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: imageURL) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(width: 335, height: 100)
            .clipped()
            .frame(maxWidth: .infinity, alignment: .center)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [Color.black.opacity(0.0), Color.black.opacity(0.35)]),
                    startPoint: .center,
                    endPoint: .bottom
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
            )

          
        }
    }
}

#Preview("CurationView") {
    CurationView()
}
//#Preview("CurationView (API 연결)") {
//    let keychain = KeychainSwift()
//    keychain.set(
//        "ya29.a0AS3H6NwWuWOm7AtByjlVNDyCNwE4tusCy-PHpYGn-qFjVUEz0L1L7U_3QejN-dQHDjFmjNKVAEvwOLSYtUar6hco89BfTz_ku11CU-bLVnHvnTCO17YrGTB79C3zi7DDV5EgvhR2mYKiCfvIB_B0Do8iekjGjwpf7y0k5V4ZaCgYKAZwSARMSFQHGX2MiCtU2hKNQdSPbJ6c77SsMRg0175",
//        forKey: "accessToken"
//    )
//
//    return CurationView()
//}
