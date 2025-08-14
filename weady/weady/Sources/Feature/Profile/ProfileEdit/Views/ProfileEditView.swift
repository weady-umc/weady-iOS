import SwiftUI

struct ProfileEditView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var nickname: String = "현재 닉네임"
    @State private var profileImage: Image? = Image(systemName: "person.circle.fill")
    @State private var showImagePicker = false

    var body: some View {
        VStack {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                        .font(.title3)
                }
                Spacer()
                Text("프로필 편집")
                    .font(.headline)
                Spacer()
                Button("완료") {
                }
                .foregroundColor(.black)
            }
            .padding()
            
            Spacer().frame(height: 20)
            
            //MARK: - 프로필 이미지
            ZStack(alignment: .bottomTrailing) {
                if let image = profileImage {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .foregroundColor(.gray.opacity(0.5))
                }
                
                Button(action: { showImagePicker = true }) {
                    Image(systemName: "camera.fill")
                        .foregroundColor(.white)
                        .padding(6)
                        .background(Color.gray)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                }
                .offset(x: 5, y: 5)
            }
            .frame(width: 100, height: 100)
            .padding(.bottom, 32)
            
            // 닉네임 입력
            VStack(alignment: .leading, spacing: 8) {
                Text("닉네임")
                    .font(.subheadline)
                    .foregroundColor(.black)
                
                TextField("현재 닉네임", text: $nickname)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.gray.opacity(0.4)))
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .sheet(isPresented: $showImagePicker) {
            // 이미지 선택 뷰 연결
            Text("이미지 선택 뷰")
        }
    }
}

#Preview {
    ProfileEditView()
}
