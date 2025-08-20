import SwiftUI
import PhotosUI

struct PhotoAddView: View {
    @Binding var images: [LocalImage]
    @State private var selectedItems: [PhotosPickerItem] = []

    private let maxImages = 10 // 사진 추가 최대 10개

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 5) {
                ForEach(images) { image in
                    Image(uiImage: image.image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 85, height: 113)
                        .clipped()
                        .cornerRadius(10)
                }

                // 사진 추가 버튼 (최대 10개)
                if images.count < maxImages {
                    PhotosPicker(
                        selection: $selectedItems,
                        maxSelectionCount: maxImages - images.count,
                        matching: .images
                    ) {
                        VStack(spacing: 4) {
                            Image("imagePlus")
                                .resizable()
                                .frame(width: 25, height: 25)
                            Text("사진을\n추가해 주세요")
                                .fontName(.metaMedium12)
                                .multilineTextAlignment(.center)
                        }
                        .frame(width: 85, height: 113)
                        .background(Color.white400)
                        .foregroundStyle(Color.gray200)
                        .cornerRadius(10)
                    }
                }
            }
            .padding(.horizontal, 5)
        }
        .task(id: selectedItems) {
            await loadImages()
        }
    }

    // MARK: - 선택한 사진을 LocalImage로 변환
    private func loadImages() async {
        var newImages: [LocalImage] = []

        for item in selectedItems {
            do {
                if let data = try await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    newImages.append(LocalImage(image: uiImage))
                }
            } catch {
                print("이미지 로드 실패:", error.localizedDescription)
            }
        }
        await MainActor.run {images.append(contentsOf: newImages)}
        selectedItems = []
    }
}
