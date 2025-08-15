import SwiftUI

struct MyPageProfile: View {
    let profile: MypageProfileModel?
    
    var body: some View {
        HStack(spacing: 11) {
            // MARK: - 프로필 이미지
            ZStack {
                if let urlStr = profile?.profileImageUrl,
                   urlStr.starts(with: "http"),
                   let url = URL(string: urlStr) {
                    AsyncImage(url: url) { img in
                        img.resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image("basicProfileImg")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }
                } else {
                    Image("basicProfileImg")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
            }
            .frame(width: 60, height: 60)
            .clipShape(Circle())
            
            // MARK: - 닉네임
            Text(profile?.name ?? "닉네임")
                .fontName(.bodySemibold16)
            
            Spacer()
        }
    }
}
