import SwiftUI

struct TagList: View {
    @Binding var selectedTags: [FashionTag]
    
    var onRemoveItem: (FashionTag) -> Void

    var body: some View {
        ForEach(selectedTags) { tag in
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(tag.brandName)
                        .fontName(.captionSemibold14)
                    Text(tag.productName)
                        .fontName(.metaRegular12)
                        .foregroundColor(.gray)
                }
                Spacer()

                Button(action: {
                    onRemoveItem(tag)
                }) {
                    Image(.xmark)
                        .scaledToFit()
                        .frame(width: 10, height: 10)
                        .padding(.horizontal, 17)
                }
            }
            Divider()
        }
    }
}

