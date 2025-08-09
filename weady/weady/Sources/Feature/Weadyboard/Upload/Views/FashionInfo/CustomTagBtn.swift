import SwiftUI

// MARK: - 제품 직접 추가 버튼

struct CustomTagBtn: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("원하는 제품이 없다면?")
                        .fontName(.metaRegular10)
                        .foregroundStyle(Color.gray300)
                    Text("제품 직접 추가하기")
                        .fontName(.captionRegular14)
                        .foregroundStyle(Color.gray200)
                }
                Spacer()
                Image(.rightIcon)
                    .resizable()
                    .frame(width: 8, height: 14)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
        }
    }
}

// MARK: - 제품 추가 시트
struct CustomSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var brandName: String = ""
    @State private var productName: String = ""

    var onAdd: (FashionTag) -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("브랜드명")
                            .fontName(.captionSemibold14)
                            .foregroundStyle(Color.black100)

                        TextField("", text: $brandName)
                            .padding(.horizontal, 12)
                            .frame(height: 44)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .inset(by: 0.5)
                                    .stroke(Color.gray400)
                            )

                        Text("제품명")
                            .fontName(.captionSemibold14)
                            .foregroundStyle(Color.black100)
                            .padding(.top, 22)

                        TextField("", text: $productName)
                            .padding(.horizontal, 12)
                            .frame(height: 44)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .inset(by: 0.5)
                                    .stroke(Color.gray400)
                            )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 45)
                }

                Button("제품 정보 추가") {
                    let tag = FashionTag(brandName: brandName, productName: productName)
                    onAdd(tag)
                    dismiss()
                }
                .disabled(brandName.trimmingCharacters(in: .whitespaces).isEmpty ||
                          productName.trimmingCharacters(in: .whitespaces).isEmpty)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.black100)
                .cornerRadius(10)
                .foregroundStyle(Color.white100)
                .fontName(.captionSemibold14)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .navigationTitle("제품 직접 추가")
            .navigationBarTitleDisplayMode(.inline)
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
            }
        }
    }
}
