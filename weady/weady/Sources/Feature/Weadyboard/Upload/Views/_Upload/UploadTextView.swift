import SwiftUI

struct UploadTextView: View {
    @Binding var content: String
    @FocusState private var isFocused: Bool

    private let placeholder = "오늘 하루는 어땠나요?\n날씨는 어땠는지, 어떤 경험을 했는지 기록으로 남겨보세요!"

    var body: some View {
        ZStack(alignment: .topLeading) {
            if content.isEmpty && !isFocused {
                Text(placeholder)
                    .foregroundStyle(Color.gray900)
                    .fontName(.metaRegular12)
                    .transition(.opacity)
            }

            TextEditor(text: $content)
                .focused($isFocused)
                .frame(height: 150)
                .foregroundStyle(Color.black100)
                .fontName(.metaRegular12)
                .scrollContentBackground(.hidden)
                .onChange(of: content) {
                    if content.count > 1000 {
                        content = String(content.prefix(1000))
                    }
                }
        }
        .padding(.top, 10)
    }
}
