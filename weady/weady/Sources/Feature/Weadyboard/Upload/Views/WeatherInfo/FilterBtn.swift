import SwiftUI

//MARK: - 텍스트 필터 버튼
struct FilterBtn: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .fontName(.metaSemibold12)
                .foregroundColor(isSelected ? Color.black100 : Color.white400)
                .padding(.horizontal, 15)
                .padding(.vertical, 5)
                .background(isSelected ? Color.white100 : Color.black100)
                .cornerRadius(20)
        }
        .buttonStyle(.plain)
    }
}
