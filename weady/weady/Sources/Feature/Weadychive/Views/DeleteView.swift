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
                ForEach(items) { item in
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

#Preview("DeleteView - Curation") {
    let mockItems = (0..<10).map {
        DeleteItem(id: Int64($0), imageUrl: $0 % 2 == 0 ? "curation1" : "curation2")
    }
    return NavigationStack {
        DeleteView(type: .curation,
                   items: .constant(mockItems),
                   viewModel: WeadychiveViewModel())
    }
}

#Preview("DeleteView - Weadyboard") {
    let mockItems = (0..<20).map {
        DeleteItem(id: Int64($0), imageUrl: "weadyboard\(($0 % 7) + 1)")
    }
    return NavigationStack {
        DeleteView(type: .weadyboard,
                   items: .constant(mockItems),
                   viewModel: WeadychiveViewModel())
    }
}
