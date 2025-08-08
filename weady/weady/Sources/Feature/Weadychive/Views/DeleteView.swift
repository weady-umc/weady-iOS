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
    // Removed @Binding var items: [DeleteItem]
    @ObservedObject var viewModel: WeadychiveViewModel

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
        ScrollView {
            LazyVGrid(columns: columns, spacing: 2) {
                let currentItems: [DeleteItem] = {
                    switch type {
                    case .curation:
                        return viewModel.scrappedCurationItems.map { DeleteItem(id: $0.id, imageUrl: $0.firstImgUrl) }
                    case .weadyboard:
                        return viewModel.scrappedWeadyboardItems.map { DeleteItem(id: $0.id, imageUrl: $0.imgUrl) }
                    }
                }()

                ForEach(currentItems) { item in
                    gridItemView(for: item)
                }
            }
            .padding(.horizontal, 2)
            .padding(.bottom, 0)
        }
        .ignoresSafeArea(.all, edges: .bottom)
    }

    @ViewBuilder
    private func gridItemView(for item: DeleteItem) -> some View {
        ZStack(alignment: .topTrailing) {
            Button(action: {
                if selectedItems.contains(item.id) {
                    selectedItems.remove(item.id)
                } else {
                    selectedItems.insert(item.id)
                }
            }) {
                Group {
                    if item.imageUrl.starts(with: "http") {
                        AsyncImage(url: URL(string: item.imageUrl)) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Color.gray.opacity(0.3)
                        }
                    } else {
                        Image(item.imageUrl)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }
                }
                .frame(height: type == .curation ? 240 : 164)
                .clipped()
                .overlay(
                    selectedItems.contains(item.id) ? Color.black.opacity(0.4) : Color.clear
                )
            }
            .buttonStyle(.plain)

            Image(systemName: selectedItems.contains(item.id) ? "checkmark.circle.fill" : "circle")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(.white)
                .background(Color.black.opacity(0.6))
                .clipShape(Circle())
                .padding(6)
        }
    }
}
//
//#Preview("DeleteView - Curation") {
//    NavigationStack {
//        DeleteView(type: .curation, viewModel: WeadychiveViewModel())
//    }
//}
