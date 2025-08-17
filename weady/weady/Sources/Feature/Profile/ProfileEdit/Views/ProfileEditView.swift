import SwiftUI
import PhotosUI

struct ProfileEditView: View {
    @State var viewModel: ProfileEditViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showImagePickerMenu = false
    @State private var showPhotoPicker = false
    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        VStack(spacing: 30) {
            // MARK: - 프로필 이미지
            ZStack(alignment: .bottomTrailing) {
                Group {
                    if let selectedImage = viewModel.selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFill()
                    } else if let profileImageUrl = viewModel.profileImageUrl,
                              profileImageUrl.starts(with: "http"),
                              let url = URL(string: profileImageUrl) {
                        AsyncImage(url: url) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            Image("basicProfileImg").resizable().scaledToFill()
                        }
                    } else {
                        Image("basicProfileImg")
                            .resizable()
                            .scaledToFill()
                    }
                }
                .frame(width: 80, height: 80)
                .clipShape(Circle())

                // MARK: - 사진 변경 아이콘
                Image("changeProfileIcon")
                    .resizable()
                    .frame(width: 44, height: 44)
                    .onTapGesture { showImagePickerMenu = true }
                    .padding(.trailing, -10)
                    .padding(.bottom, -12)
            }

            // MARK: - 닉네임 입력
            VStack(alignment: .leading, spacing: 12) {
                Text("닉네임")
                    .fontName(.captionSemibold14)
                TextField("닉네임", text: $viewModel.nickname)
                    .padding(10)
                    .fontName(.captionRegular14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.gray400, lineWidth: 1)
                    )
            }
            .padding(.horizontal, 20)

            Spacer()
        }
        .padding(.top, 20)
        .navigationTitle("프로필 편집")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image("backicon")
                        .resizable()
                        .frame(width: 9, height: 16)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("완료") {
                    viewModel.saveProfile { success in
                        if success { dismiss() }
                    }
                }
                .fontName(.captionMedium14)
                .foregroundStyle(Color.black100)
            }
        }
        .safeAreaInset(edge: .top, spacing: 6) {
            Divider()
        }
        // MARK: - 액션시트 & PhotosPicker
        .actionSheet(isPresented: $showImagePickerMenu) {
            ActionSheet(title: Text("프로필 사진 설정"),
                        buttons: [
                            .default(Text("앨범에서 사진 선택")) { showPhotoPicker = true },
                            .default(Text("기본 이미지 적용")) { viewModel.setDefaultProfileImage() },
                            .cancel(Text("취소"))
                        ])
        }
        .photosPicker(isPresented: $showPhotoPicker, selection: $selectedItem, matching: .images)
        .onChange(of: selectedItem) { oldItem, newItem in
            guard let newItem else { return }
            
            Task {
                do {
                    if let imageData = try await newItem.loadTransferable(type: Data.self),
                       let image = UIImage(data: imageData) {
                        await MainActor.run {
                            viewModel.setProfileImage(image)
                        }
                    }
                } catch {
                    print("이미지 선택 실패: \(error)")
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    let dummyProfile = MypageProfileModel(id: 1, name: "현재 닉네임", profileImageUrl: nil)
    let dummyMypageVM = MypageViewModel()
    dummyMypageVM.updateProfile(dummyProfile)

    return NavigationStack {
        ProfileEditView(viewModel: ProfileEditViewModel(mypageViewModel: dummyMypageVM))
    }
}
