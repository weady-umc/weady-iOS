

import SwiftUI

/// Curation 첫 화면 (PlaceView 레이아웃을 유지하면서 MVVM 바인딩)
struct CurationView: View {
    @StateObject private var vm = CurationViewModel()

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                // 1) 상단 텍스트: [가변] + [고정]
                HeaderView(leading: vm.headerText.leading,
                           trailing: vm.headerText.trailing)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                // 2) 장소 원형 칩 스크롤
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(vm.tags) { tag in
                            TagChip(tag: tag, isSelected: tag.id == vm.selectedTag.id && tag.kind == vm.selectedTag.kind)
                                .onTapGesture {
                                    Task { await vm.select(tag: tag) }
                                }
                        }
                    }
                    .padding(.horizontal, 16)
                }

                // 3) 카드 리스트 (4개)
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(vm.cards) { card in
                            Button {
                                Task { await vm.openDetail(curationId: card.id) }
                            } label: {
                                CardRow(title: card.title, imageURL: card.thumbnailURL)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.top, 8)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .task { await vm.boot() }
    }
}

// MARK: - Header
private struct HeaderView: View {
    let leading: String
    let trailing: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 0) {
                Text(leading)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(red: 1.0, green: 0.45, blue: 0.6)) // Figma의 포인트색 유사
                Text("에는")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
            }
            Text(trailing)
                .font(.system(size: 20, weight: .bold))
        }
    }
}

// MARK: - TagChip (원형, 띄어쓰기 줄바꿈, 선택 시 테두리 강조)
private struct TagChip: View {
    let tag: LocationTag
    let isSelected: Bool

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
        .background(
            ZStack {
                Circle().fill(Color.white)
                Circle().stroke(isSelected ? Color.yellow : Color.black.opacity(0.85), lineWidth: 1.5)
            }
        )
        .frame(width: 63, height: 63)
        .clipShape(Circle())
    }
}

// MARK: - Card Row (썸네일 + 좌하단 타이틀)
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
            .frame(height: 160)
            .frame(maxWidth: .infinity)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 10))

            // 타이틀 오버레이 (가독성 높이기 위해 살짝 그림자)
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .shadow(radius: 2)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
        }
    }
}

#Preview("CurationView") {
    CurationView()
}
