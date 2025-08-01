import SwiftUI

struct UploadView: View {
    @StateObject private var viewModel = UploadViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                PhotoUploadView(images: $viewModel.uploadedImages)

                TextEditor(text: $viewModel.content)
                    .frame(height: 120)
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))

                VStack(spacing: 16) {
                    NavBtn(title: "날씨 정보 추가", isRequired: true) {
                        AnyView(PlaceholderView(title: "날씨 정보 추가"))
                    }

                    NavBtn(title: "패션 정보 추가") {
                        AnyView(PlaceholderView(title: "패션 정보 추가"))
                    }

                    NavBtn(title: "장소 정보 추가") {
                        AnyView(PlaceholderView(title: "장소 정보 추가"))
                    }

                    ToggleBtn(label: "커뮤니티 게시", isOn: $viewModel.isPublic)
                    
                    ToggleBtn(label: "유료 광고 포함", isOn: $viewModel.includesAd)
                }

                Button(action: {
                    Task {
                        try? await viewModel.submitPost()
                    }
                }) {
                    Text("등록하기")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.isFormValid ? Color.black : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(!viewModel.isFormValid)
            }
            .padding()
        }
        .navigationTitle("새 게시물")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PlaceholderView: View {
    let title: String

    var body: some View {
        VStack {
            Spacer()
            Text("\(title) 화면은 아직 구현되지 않았습니다.")
                .multilineTextAlignment(.center)
                .padding()
                .foregroundColor(.gray)
            Spacer()
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    UploadView()
}

