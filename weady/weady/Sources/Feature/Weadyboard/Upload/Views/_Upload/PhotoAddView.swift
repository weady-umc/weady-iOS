import SwiftUI
import PhotosUI

struct PhotoAddView: View {
    @Binding var images: [LocalImage]
    @State private var selectedItems: [PhotosPickerItem] = []

    private let maxImages = 10 // 사진 추가 최대 10개

    var body: some View {
        // MARK: - 사진 추가 스크롤뷰
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
                
                // MARK: - 사진 추가 아이콘 (최대 10개 추가시 아이콘 숨김)
                if images.count < maxImages {
                    PhotosPicker(
                        selection: $selectedItems,
                        maxSelectionCount: maxImages - images.count,
                        matching: .images
                    ) {
                        VStack(alignment: .center, spacing: 4) {
                            Image("imagePlus")
                                .frame(width: 25, height: 25)
                            Text("사진을\n추가해 주세요")
                                .fontName(.metaMedium12)
                                .multilineTextAlignment(.center)
                        }
                        .frame(width: 85, height: 113, alignment: .center)
                        .background(Color.white400)
                        .foregroundStyle(Color.gray200)
                        .cornerRadius(10)
                    }
                }
            }
        }
        .task(id: selectedItems) {
            await loadImages()
        }
    }
    
    //MARK: - 추가된 사진을 배열로 저장하는 함수
    private func loadImages() async {
        var newImages: [LocalImage] = []

        for item in selectedItems {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                newImages.append(LocalImage(image: uiImage))
            }
        }

        await MainActor.run {
            images.append(contentsOf: newImages)
        }

        selectedItems = []
    }
}
