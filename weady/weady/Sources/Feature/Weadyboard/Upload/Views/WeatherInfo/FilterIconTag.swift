import SwiftUI

struct FilterIconTag: View {
    let label: String
    let iconName: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            Image(iconName)
                .resizable()
                .scaledToFit()
            Text(label)
                .fontName(.metaMedium12)
        }
        .foregroundColor(isSelected ? Color.black100 : Color.white400)
        .padding(.horizontal, 12)
        .padding(.vertical, 5)
        .background(isSelected ? Color.white100 : Color.black100)
        .cornerRadius(20)
        .onTapGesture(perform: action)
    }
}
