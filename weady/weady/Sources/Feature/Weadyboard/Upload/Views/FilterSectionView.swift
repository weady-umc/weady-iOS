import SwiftUI

struct FilterSectionView<Content: View>: View {
    let title: String
    let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .fontName(.metaSemibold12)
                .foregroundColor(.black100)
                .padding(.leading, 10)

            Divider()
                .background(Color.gray600)
                .frame(height: 1)

            content()
        }
    }
}
