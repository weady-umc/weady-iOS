import Foundation
import SwiftUI

struct SelectableChipsView: View {
    let options: [String]
    @Binding var selected: String

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
            ForEach(options, id: \.self) { option in
                Button(action: { selected = option }) {
                    HStack(spacing: 4) {
                        iconName(for: option)
                        Text(option)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(selected == option ? Color.black : Color.gray.opacity(0.15))
                    .foregroundColor(selected == option ? .white : .primary)
                    .clipShape(Capsule())
                }
            }
        }
    }

    func iconName(for weather: String) -> Image {
        switch weather {
        case "맑은 날": return Image(.sun)
        case "구름 많은 날": return Image(.cloud)
        case "비 오는 날": return Image(.rain)
        case "흐린 날": return Image(.cloudsun)
        case "눈 오는 날": return Image(.snow)
        case "바람 많은 날": return Image(.wind)
        default: return Image(.wind)
        }
    }
}

