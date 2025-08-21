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
  
    @ObservedObject var viewModel: WeadychiveViewModel

    @Environment(\.dismiss) private var dismiss
    @State private var selectedItems: Set<Int64> = []

    var title: String {
        switch type {
        case .curation: return "취소할 항목"
        case .weadyboard: return "취소할 항목"
        }
    }
    
    private var itemHeight: CGFloat {
        switch type {
        case .curation:
            return 300
        case .weadyboard:
            return 160
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
            headerView
            gridView
        }
        .background(Color.white)
    }

    private var headerView: some View {
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

                switch type {
                case .curation:
                    viewModel.deleteCurationItems(with: deletedIDs)
                case .weadyboard:
                    viewModel.deleteWeadyboardItems(with: deletedIDs)
                }

                selectedItems.removeAll()
                dismiss()
            }) {
                Text("완료")
                    .fontName(.captionMedium14)
                    .foregroundColor(selectedItems.isEmpty ? .gray : .black100)
            }
            .disabled(selectedItems.isEmpty)
        }
        .padding()
    }

    private var gridView: some View {
        GeometryReader { proxy in
            // Common spacing/padding values
            let spacing: CGFloat = 2
            let sidePadding: CGFloat = 2

            // Build columns depending on type
            let columns: [GridItem] = {
                switch type {
                case .curation:
                    // Keep previous behavior: 2 flexible columns
                    return [GridItem(.flexible(), spacing: spacing),
                            GridItem(.flexible(), spacing: spacing)]
                case .weadyboard:
                    // Make 3 fixed columns with a computed square size
                    let count = 3
                    let totalSpacing = spacing * CGFloat(count - 1) + (sidePadding * 2)
                    let cell = floor((proxy.size.width - totalSpacing) / CGFloat(count))
                    return Array(repeating: GridItem(.fixed(cell), spacing: spacing), count: count)
                }
            }()

            // Precompute cell length for weadyboard; nil for curation
            let cellLength: CGFloat? = {
                if case .weadyboard = type {
                    let count = 3
                    let totalSpacing = spacing * CGFloat(count - 1) + (sidePadding * 2)
                    return floor((proxy.size.width - totalSpacing) / CGFloat(count))
                }
                return nil
            }()

            ScrollView {
                LazyVGrid(columns: columns, spacing: spacing) {
                    let currentItems: [DeleteItem] = {
                        switch type {
                        case .curation:
                            return viewModel.scrappedCurationItems.map { DeleteItem(id: $0.id, imageUrl: $0.firstImgUrl) }
                        case .weadyboard:
                            return viewModel.scrappedWeadyboardItems.map { DeleteItem(id: $0.id, imageUrl: $0.imgUrl ?? "") }
                        }
                    }()

                    ForEach(currentItems) { item in
                        gridItemView(for: item, cell: cellLength)
                    }
                }
                .padding(.horizontal, sidePadding)
                .padding(.bottom, 0)
            }
            .ignoresSafeArea(.all, edges: .bottom)
        }
    }

    @ViewBuilder
    private func gridItemView(for item: DeleteItem, cell: CGFloat?) -> some View {
        Button(action: {
            if selectedItems.contains(item.id) {
                selectedItems.remove(item.id)
            } else {
                selectedItems.insert(item.id)
            }
        }) {
            ZStack {
                // Base placeholder to stabilize layout
                Rectangle()
                    .fill(Color.gray.opacity(0.18))

                if item.imageUrl.isEmpty {
                    // nothing; placeholder remains
                } else if item.imageUrl.hasPrefix("http"), let url = URL(string: item.imageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: cell ?? nil, height: cell ?? itemHeight)
                                .clipped()
                        case .failure(_):
                            Image(systemName: "photo")
                                .font(.system(size: 22))
                                .foregroundStyle(.gray)
                        case .empty:
                            ProgressView()
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Image(item.imageUrl)
                        .resizable()
                        .scaledToFill()
                        .frame(width: cell ?? nil, height: cell ?? itemHeight)
                        .clipped()
                }
            }
            .frame(width: cell ?? nil, height: cell ?? itemHeight)
        }
        .contentShape(Rectangle())
        .buttonStyle(.plain)
        // 선택 시 dim 처리
        .overlay(
            (selectedItems.contains(item.id) ? Color.black.opacity(0.35) : Color.clear)
                .allowsHitTesting(false)
        )
        // 체크마크는 항상 맨 위에 고정
        .overlay(alignment: .topTrailing) {
            let isSelected = selectedItems.contains(item.id)
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(Color.white)
                .frame(width: 24, height: 24)
                .background(Circle().fill(Color.black.opacity(0.6)))
                .padding(6)
                .zIndex(1)
                .allowsHitTesting(false)
        }
    }
}
