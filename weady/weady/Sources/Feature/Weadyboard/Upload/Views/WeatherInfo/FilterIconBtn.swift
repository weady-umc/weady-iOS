import SwiftUI

//MARK: - 아이콘&텍스트 필터 버튼
struct FilterIconBtn: View {
    let label: String
    let iconName: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 14, height: 14)
                Text(label)
                    .fontName(.metaMedium12)
            }
            .foregroundColor(isSelected ? Color.black100 : Color.white400)
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(isSelected ? Color.white100 : Color.black100)
            .cornerRadius(20)
        }
        .buttonStyle(.plain)
    }
}
