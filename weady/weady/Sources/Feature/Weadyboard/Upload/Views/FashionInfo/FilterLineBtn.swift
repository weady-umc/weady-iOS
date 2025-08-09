import SwiftUI

struct FilterLineBtn: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .fontName(.metaMedium12)
                .padding(.vertical, 5)
                .padding(.horizontal, 15)
                .background(Color.white400)
                .foregroundStyle(Color.black100)
                .cornerRadius(20)
                .lineLimit(1)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.gray100 : Color.clear, lineWidth: 1.5)
                )
        }
    }
}
