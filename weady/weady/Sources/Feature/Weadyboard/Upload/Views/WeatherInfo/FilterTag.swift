import SwiftUI

struct FilterTag: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Text(text)
            .fontName(.metaSemibold12)
            .foregroundColor(isSelected ? Color.black100 : Color.white400)
            .padding(.horizontal, 15)
            .padding(.vertical, 5)
            .background(isSelected ? Color.white100 : Color.black100)
            .cornerRadius(20)
            .onTapGesture(perform: action)
    }
}
