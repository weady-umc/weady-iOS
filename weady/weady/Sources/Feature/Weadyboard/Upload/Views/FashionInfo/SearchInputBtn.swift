import SwiftUI

// MARK: - 검색 입력창 (클릭 시, 검색 시트뷰로 이동)
struct SearchInputBtn: View {
    @Binding var text: String
    var viewModel: FashionViewModel

    @State private var showSearchSheet = false

    var body: some View {
        HStack {
            Button {
                showSearchSheet.toggle()
            } label: {
                HStack {
                    Image(.uploadSearchIcon)
                        .scaledToFit()
                        .frame(width: 17, height: 17)
                    Text("브랜드명, 제품명을 입력하세요")
                        .foregroundStyle(Color.gray300)
                        .fontName(.captionRegular14)
                    Spacer()
                }
                .padding(10)
                .background(Color.white400)
                .cornerRadius(6)
                .frame(height: 40)
            }
            .sheet(isPresented: $showSearchSheet) {
                SearchSheetView(searchQuery: $text, viewModel: viewModel)
                    .presentationDetents([.height(567)])
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 제품 검색 시트뷰 (제품을 검색하고 선택하면 태그 추가)
struct SearchSheetView: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var searchQuery: String
    var viewModel: FashionViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                //MARK: - 검색창
                SearchInputBar(searchText: $searchQuery, placeholder: "브랜드명, 제품명을 입력하세요")

                //MARK: - 검색 결과 리스트
                List {
                    ForEach(filteredResults, id: \.self) { tag in
                        Button {
                            viewModel.addTag(tag)
                            dismiss()
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(tag.brandName)
                                        .fontName(.captionSemibold14)
                                        .foregroundStyle(Color.black100)
                                    Text(tag.productName)
                                        .fontName(.metaRegular12)
                                        .foregroundStyle(Color.gray300)
                                }
                                Spacer()
                                // 이미 선택된 제품 체크 표시
                                if viewModel.selectedTags.contains(tag) {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(Color.black100)
                                }
                            }
                            .padding(.vertical, 6)
                        }
                        .disabled(viewModel.selectedTags.contains(tag) || viewModel.selectedTags.count >= 3)
                        .listRowSeparator(.automatic)
                        .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("제품 검색")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image("backicon")
                            .resizable()
                            .frame(width: 9, height: 16)
                    }
                }
            }
            .onAppear {
                viewModel.loadMoreSearchResults()
            }
            .onChange(of: searchQuery) {
                viewModel.loadMoreSearchResults()
            }
        }
    }
    
    //MARK: - 검색 결과 함수
    private var filteredResults: [FashionTag] {
        guard !searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return []
        }

        return viewModel.dummySearchResults.filter {
            $0.brandName.localizedCaseInsensitiveContains(searchQuery) ||
            $0.productName.localizedCaseInsensitiveContains(searchQuery)
        }
    }
}
