import SwiftUI

struct SearchList<Item: Identifiable & Equatable>: View {
    let results: [Item]
    let selectedItems: [Item]
    let nameProvider: (Item) -> String
    let detailProvider: (Item) -> String
    let onItemSelected: (Item) -> Void

    var body: some View {
        List {
            ForEach(results, id: \.id) { item in
                Button {
                    onItemSelected(item)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(nameProvider(item))
                                .fontName(.captionSemibold14)
                                .foregroundStyle(Color.black100)
                            Text(detailProvider(item))
                                .fontName(.metaRegular12)
                                .foregroundStyle(Color.gray300)
                        }
                        Spacer()
                        if selectedItems.contains(item) {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color.black100)
                        }
                    }
                    .padding(.vertical, 6)
                }
                .disabled(selectedItems.contains(item) || selectedItems.count >= 3)
                .listRowSeparator(.automatic)
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .frame(
            maxHeight: CGFloat(min(results.count, 7)) * 56 // 한 뷰에 최대 6개까지 보이도록 설정
        )
    }
}
