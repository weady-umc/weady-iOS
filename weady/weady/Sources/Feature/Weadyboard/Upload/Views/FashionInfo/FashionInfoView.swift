import SwiftUI

struct FashionInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: FashionViewModel
    
    var onComplete: (() -> Void)? = nil
    
    @State private var showAddSheet = false
    @State private var brandName: String = ""
    @State private var productName: String = ""
    @State private var isSearching: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // MARK: - 스타일 추가
                FilterSection(title: "스타일 추가") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 1), count: 5), spacing: 15) {
                        ForEach(viewModel.allStyles, id: \.self) { style in
                            FilterLineBtn(
                                title: style.displayName,
                                isSelected: viewModel.fashion.selectedStyles.contains(style)
                            ) {
                                viewModel.toggleStyle(style)
                            }
                        }
                    }
                }
                .padding(.bottom, 50)
                
                // MARK: - 태그 추가
                VStack(alignment: .leading, spacing: 5) {
                    FilterSection(title: "태그 추가") {
                        // 제품 검색 버튼 (제품 검색 시트뷰로 이동)
                        SearchInputBtn(text: $viewModel.searchQuery, viewModel: viewModel)
                        
                        // 제품 직접 추가 버튼 (제품 직접 추가 시트뷰로 이동)
                        CustomTagBtn {
                            showAddSheet = true
                        }
                        .sheet(isPresented: $showAddSheet) {
                            CustomSheetView { tag in
                                viewModel.addTag(tag)
                            }
                            .presentationDetents([.fraction(1.0)])
                        }
                        
                        Divider()
                        
                        // MARK: - 선택된 태그 리스트 (최대 3개까지 선택 가능)
                        SearchItemList(
                            items: $viewModel.fashion.selectedTags,
                            nameProvider: { (tag: FashionTag) in tag.brandName },
                            detailProvider: { (tag: FashionTag) in tag.productName },
                            onRemove: viewModel.removeTag
                        )
                    }
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .navigationTitle("패션 정보 추가")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
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
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("완료") {
                    print("- 스타일: \(viewModel.fashion.selectedStyles.map { $0.displayName })")
                    print("- 태그: \(viewModel.fashion.selectedTags)")
                    onComplete?()
                    dismiss()
                }
                .fontName(.captionMedium14)
                .foregroundStyle(Color.black100)
            }
        }
        .onAppear {
            if viewModel.dummySearchResults.isEmpty {
                viewModel.loadMoreSearchResults()
            }
        }
    }
}

#Preview {
    FashionInfoView(viewModel: FashionViewModel())
}
