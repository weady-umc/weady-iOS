import SwiftUI

struct MyPageProfile: View {
    let profile: MypageProfileModel?
    
    var body: some View {
        HStack(spacing: 11) {
            //MARK: - 프로필 이미지
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 60, height: 60)
                .background(
                    Group {
                        if let urlStr = profile?.profileImageUrl,
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
                    .clipped()
                )
                .cornerRadius(60)
            
            //MARK: - 닉네임
            Text(profile?.name ?? "닉네임")
                .fontName(.bodySemibold16)
            
            Spacer()
        }
    }
}
