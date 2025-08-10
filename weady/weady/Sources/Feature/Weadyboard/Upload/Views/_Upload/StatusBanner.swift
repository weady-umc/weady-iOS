import SwiftUI

struct StatusBanner: View {
    enum BannerType {
        case `public`
        case `private`
    }

    let type: BannerType

    var body: some View {
        HStack(alignment: .center, spacing: 5) {
            Image(iconName)
                .resizable()
                .frame(width: 10, height: 10)

            Text(message)
                .fontName(.metaRegular10)

            Spacer()
        }
        .padding(.leading, 9)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 33)
        .foregroundStyle(Color.gray300)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.gray400, lineWidth: 1)
        )
    }

    private var iconName: String {
        switch type {
        case .public:
            return "publicIcon"
        case .private:
            return "privateIcon"
        }
    }

    private var message: String {
        switch type {
        case .public:
            return "공유중 : 모든 사용자가 볼 수 있는 글이에요. 공유 전 내용을 꼭 확인해주세요."
        case .private:
            return "보관중 : 이 글은 나만 볼 수 있는 마이페이지에 보관돼요."
        }
    }
}
