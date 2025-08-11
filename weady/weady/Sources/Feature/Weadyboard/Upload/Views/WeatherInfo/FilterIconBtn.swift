import SwiftUI

struct FilterIconBtn: View {
    let title: String
    let imageName: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(imageName)
                    .scaledToFit()
                    
                Text(title)
                    .fontName(.metaMedium12)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .foregroundStyle(isSelected ? Color.white100 : Color.black100)
            .background(isSelected ? Color.black100 : Color.white400)
            .cornerRadius(20)
        }
    }
}
