import SwiftUI

struct FilterBtn: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .fontName(.metaSemibold12)
                .foregroundStyle(isSelected ? Color.white100 : Color.black100)
                .padding(.horizontal, 15)
                .padding(.vertical, 5)
                .background(isSelected ? Color.black100 : Color.white400)
                .cornerRadius(20)
        }
    }
}
