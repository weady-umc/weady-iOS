import SwiftUI

struct PlaceInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @State var viewModel: PlaceViewModel
    @State private var isSearching = false

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - 검색창
            SearchInputBar(
                searchText: $viewModel.searchQuery,
                placeholder: "장소명을 입력하세요"
            )
            .padding(.top, 12)
            .onChange(of: viewModel.searchQuery) { _, newValue in
                isSearching = !newValue.trimmingCharacters(in: .whitespaces).isEmpty
                viewModel.searchPlaces()
            }


            // MARK: - 검색 중일 때만 검색 리스트 표시
            if isSearching {
                if viewModel.searchResults.isEmpty {
                    Text("검색 결과가 없습니다.")
                        .fontName(.metaRegular10)
                        .foregroundStyle(Color.gray300)
                        .padding(.top, 24)
                } else {
                    SearchList(
                        results: viewModel.searchResults,
                        selectedItems: viewModel.selectedPlaces,
                        nameProvider: { $0.placeName },
                        detailProvider: { $0.placeAddress },
                        onItemSelected: { place in
                            viewModel.addPlace(place)
                            // 검색 종료
                            viewModel.searchQuery = ""
                            isSearching = false
                        }
                    )
                }
            } else {
                // 검색 리스트에서 아이템이 선택되면 선택된 장소들 목록만 표시
                SearchItemList(
                    items: $viewModel.selectedPlaces,
                    nameProvider: { $0.placeName },
                    detailProvider: { $0.placeAddress },
                    onRemove: viewModel.removePlace
                )
            }

            Spacer()
        }
        .navigationTitle("위치")
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
                    print("- 장소명 : \(viewModel.selectedPlaces)")
                    dismiss()
                }
                .fontName(.captionMedium14)
                .foregroundStyle(Color.black100)
                .disabled(viewModel.selectedPlaces.isEmpty)
            }
        }
        .onChange(of: viewModel.searchQuery) {
            viewModel.searchPlaces()
        }
    }
}

#Preview {
    PlaceInfoView(viewModel: PlaceViewModel())
}
