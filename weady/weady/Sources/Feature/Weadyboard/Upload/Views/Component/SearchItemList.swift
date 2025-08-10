import SwiftUI

struct SearchItemList<Item: Identifiable & Hashable>: View {
    @Binding var items: [Item]
    var nameProvider: (Item) -> String
    var detailProvider: (Item) -> String
    var onRemove: ((Item) -> Void)? = nil

    var body: some View {
        VStack(spacing: 0) {
            ForEach(items) { item in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(nameProvider(item))
                            .fontName(.captionSemibold14)
                            .foregroundStyle(Color.black100)

                        Text(detailProvider(item))
                            .fontName(.metaRegular10)
                            .foregroundStyle(Color.gray300)
                    }

                    Spacer()

                    Button(action: {
                        // 목록에서 제거
                        if let index = items.firstIndex(of: item) {
                            items.remove(at: index)
                        }
                        // 외부에서도 처리하고 싶을 경우
                        onRemove?(item)
                    }) {
                        Image(systemName: "xmark")
                            .resizable()
                            .frame(width: 12, height: 12)
                            .foregroundStyle(Color.gray300)
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)

                Divider()
                    .padding(.leading, 16)
            }
        }
    }
}
