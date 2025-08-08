//////
//  DeleteView.swift
//  weady
//
//  Created by 고석현 on 7/28/25.
//
//
import SwiftUI

struct DeleteItem: Identifiable, Hashable {
    let id: Int64
    let imageUrl: String
}

struct DeleteView: View {
    enum DeleteType {
        case curation
        case weadyboard
    }

    let type: DeleteType
    @Binding var items: [DeleteItem]
    var onDelete: ([Int64]) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedItems: Set<Int64> = []

    var title: String {
        switch type {
        case .curation: return "취소할 항목"
        case .weadyboard: return "취소할 항목"
        }
    }

    var columns: [GridItem] {
        switch type {
        case .curation:
            return [GridItem(.flexible(), spacing: 2), GridItem(.flexible(), spacing: 2)]
        case .weadyboard:
            return [GridItem(.flexible(), spacing: 2), GridItem(.flexible(), spacing: 2), GridItem(.flexible(), spacing: 2)]
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                        .padding(.trailing, 8)
                }
                Spacer()
                Text(title)
                    .fontName(.bodySemibold16)
                Spacer()
                Button(action: {
                    let deletedIDs = Array(selectedItems)
                    onDelete(deletedIDs) // 서버 통신은 이 클로저에서 수행됨
                    selectedItems.removeAll()
                    dismiss() // 이전 화면으로 돌아가기
                }) {
                    Text("완료")
                        .fontName(.captionMedium14)
                        .foregroundColor(selectedItems.isEmpty ? .gray100 : .black100)
                }
                .disabled(selectedItems.isEmpty)
            }
            .padding()

            ScrollView {
                LazyVGrid(columns: columns, spacing: 2) {
                    ForEach(items) { item in
                        ZStack(alignment: .topTrailing) {
                            Button(action: {
                                if selectedItems.contains(item.id) {
                                    selectedItems.remove(item.id)
                                } else {
                                    selectedItems.insert(item.id)
                                }
                            }) {
                                AsyncImage(url: URL(string: item.imageUrl)) { image in
                                    image.resizable()
                                         .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Color.gray.opacity(0.3)
                                }
                                .frame(height: type == .curation ? 240 : 164)
                                .clipped()
                                .overlay(
                                    Group {
                                        if selectedItems.contains(item.id) {
                                            Color.black.opacity(0.4)
                                        }
                                    }
                                )
                            }
                            .buttonStyle(.plain)

                            if selectedItems.contains(item.id) {
                                Image(systemName: "checkmark.circle.fill")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.white)
                                    .background(Color.black.opacity(0.6))
                                    .clipShape(Circle())
                                    .padding(6)
                            }
                        }
                    }
                }
                .padding(2)
            }
        }
        .background(Color.white)
    }
}

// MARK: - Preview
#Preview {
    struct DeleteViewPreviewWrapper: View {
        @State private var mockItems: [DeleteItem] = (1...12).map { DeleteItem(id: Int64($0), imageUrl: "https://via.placeholder.com/150") }
        
        var body: some View {
            DeleteView(type: .curation, items: $mockItems) { deleted in
                print("Deleted items: \(deleted)")
            }
        }
    }

    return DeleteViewPreviewWrapper()
}
