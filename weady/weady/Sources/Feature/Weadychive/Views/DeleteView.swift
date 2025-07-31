//
//  DeleteView.swift
//  weady
//
//  Created by 고석현 on 7/28/25.
//

import SwiftUI

enum DeleteContentType {
    case curation, weadyboard

    var title: String {
        switch self {
        case .curation: return "스크랩한 큐레이션"
        case .weadyboard: return "스크랩한 웨디보드"
        }
    }

    var gridColumns: [GridItem] {
        switch self {
        case .curation: return Array(repeating: GridItem(.flexible(), spacing: 2), count: 2)
        case .weadyboard: return Array(repeating: GridItem(.flexible(), spacing: 2), count: 3)
        }
    }

    func imageName(for index: Int) -> String {
        switch self {
        case .curation: return index % 2 == 0 ? "curation1" : "curation2"
        case .weadyboard: return "weadyboard\((index % 7) + 1)"
        }
    }

    var imageHeight: CGFloat {
        switch self {
        case .curation: return 240
        case .weadyboard: return 164
        }
    }
}

//MARK: -스크랩 취소하기 화면
struct DeleteView: View {
    @Environment(\.dismiss) var dismiss
    let type: DeleteContentType
    @Binding var items: [Int]
    var onDelete: ([Int]) -> Void
    @State private var selectedItems: Set<Int> = []

   
    var body: some View {
        VStack(spacing: 0) {


            ScrollView {
                LazyVGrid(columns: type.gridColumns, spacing: 2) {
                    // 삭제 가능한 항목 리스트 표시
                    ForEach(items, id: \.self) { index in
                        Button {
                            if selectedItems.contains(index) {
                                selectedItems.remove(index)
                            } else {
                                selectedItems.insert(index)
                            }
                        } label: {
                            ZStack(alignment: .topTrailing) {
                                Image(type.imageName(for: index))
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: type.imageHeight)
                                    .clipped()
                                    .overlay(
                                        selectedItems.contains(index) ? Color.black.opacity(0.3) : Color.clear
                                    )

                                Image(systemName: selectedItems.contains(index) ? "checkmark.circle.fill" : "circle")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .foregroundStyle(.white)
                                    .background(Color.black.opacity(0.6))
                                    .clipShape(Circle())
                                    .padding(6)
                            }
                        }
                    }
                }
                .padding(.horizontal, 2)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.black)
                }
            }

            ToolbarItem(placement: .principal) {
                Text("취소할 항목")
                    .font(.headline)
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onDelete(Array(selectedItems))
                    }
                }) {
                    Text("완료")
                        .fontName(.captionMedium14)
                        .foregroundStyle(.black)
                }
            }
        }
    }
}




