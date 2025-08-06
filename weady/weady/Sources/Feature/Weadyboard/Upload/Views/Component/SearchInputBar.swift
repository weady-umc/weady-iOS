import SwiftUI

struct SearchInputBar: View {
    @Binding var searchText: String
    var placeholder: String

    var body: some View {
        HStack {
            Image(.searchIcon)
                .scaledToFit()
                .frame(width: 17, height: 17)

            TextField(placeholder, text: $searchText)
                .fontName(.captionRegular14)
                .foregroundStyle(Color.gray300)
        }
        .padding(.horizontal, 10)
        .frame(height: 40)
        .background(Color.white400)
        .cornerRadius(6)
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
    }
}
