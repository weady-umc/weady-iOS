import SwiftUI

struct PhotoUploadView: View {
    @Binding var images: [PostImage]

    var body: some View {
        VStack(alignment: .leading) {
            Text("사진을 추가해주세요.")
            Rectangle()
                .frame(width: 80, height: 80)
                .foregroundColor(.gray.opacity(0.2))
                .overlay(Image(systemName: "plus").font(.title))
                .onTapGesture {
                    // 이미지 추가 동작
                }
        }
    }
}
