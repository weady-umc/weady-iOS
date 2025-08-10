import SwiftUI

struct FashionFilterSection<Content: View>: View {
    let title: String
    let content: () -> Content

    init(title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .fontName(.captionSemibold14)
            Divider()
                .foregroundStyle(Color.gray600)
            content()
                .padding(.top, 10)
        }
    }
}
