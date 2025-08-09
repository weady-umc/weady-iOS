import SwiftUI

// 뷰 트리 : WeadychiveView
//TopBar -> TopTabIndicatorView -> CurationListView / WeadyboardListView
//sheetView -> DeleteView


        
//MARK: - Main 웨디카이브 뷰
struct WeadychiveView: View {
    @StateObject private var viewModel = WeadychiveViewModel()
    @Environment(NavigationRouter.self) private var router: NavigationRouter?
  
    
 
    // MARK: - 프로퍼티
    @State private var selectedTopTab: TopTab = .curation // 기본 선택 탭
    @State private var showSheet = false // 시트 표시 여부
    @State private var navigateToDelete = false // Add navigation state here
    // 추가
    @State private var deletedCurationIDs: Set<Int> = []
    @State private var deletedWeadyboardIDs: Set<Int> = []
   

    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TopBar(showSheet: $showSheet)
                    .padding(.bottom, 12)
                // Top Tab Indicator
                TopTabIndicatorView(selectedTab: $selectedTopTab)
                    .padding(.top, 12)
                
                // TODO: - 인디케이터 바에 따라서 아래 콘텐츠 분기
                Group {
                    switch selectedTopTab {
                    case .curation:
                        if viewModel.hasScrappedCurations {
                            CurationListView(items: viewModel.scrappedCurationItems) // ViewModel 연동
                        } else {
                            NoCurationView()
                        }
                    case .weadyboard:
                        if viewModel.hasScrappedWeadyboards {
                            WeadyboardListView(items: viewModel.scrappedWeadyboardItems) // ViewModel 연동
                        } else {
                            NoWeadyboardView()
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .task(id: selectedTopTab) {
                switch selectedTopTab {
                case .curation:
                    viewModel.CurationLogOutput()
                case .weadyboard:
                    viewModel.WeadyboardLogOutput(size: 18, page: 0)
                }
            }
            .onChange(of: navigateToDelete) { isPushing in
                guard isPushing == false else { return }
                switch selectedTopTab {
                case .curation:
                    viewModel.CurationLogOutput()
                case .weadyboard:
                    viewModel.WeadyboardLogOutput(size: 18, page: 0)
                }
            }
            // Sheet 표시: 더보기 탭에서 "스크랩 취소하기"를 눌렀을 때 표시
            .sheet(isPresented: $showSheet) {
                SheetView(showSheet: $showSheet) {
                    navigateToDelete = true
                }
                .presentationDetents([.height(145)])
                .presentationDragIndicator(.visible)
            }
            .navigationDestination(isPresented: $navigateToDelete) {
                if selectedTopTab == .curation {
                    DeleteView(type: .curation, viewModel: viewModel)
                        .navigationBarBackButtonHidden(true)
                } else {
                    DeleteView(type: .weadyboard, viewModel: viewModel)
                        .navigationBarBackButtonHidden(true)
                }
            }
        }
        
        
      
    }
}

// MARK: - TopBar (상단 바)

struct TopBar: View {
    @Binding var showSheet: Bool

  
    var body: some View {
        HStack {
 
            Text("웨디카이브")
                .fontName(.headingSemibold20)
            Rectangle()
              .foregroundStyle(.clear)
              .frame(width: 0.5, height: 12)
              .background(Color(red: 0.07, green: 0.07, blue: 0.07))
            Text("내가 담은 하루들")
                .fontName(.homeRegular11)
            Spacer()
            Image(systemName: "ellipsis")
                .font(.system(size: 20))
                .foregroundStyle(.black)
                .onTapGesture {
                    showSheet = true
                    
                }
        }
           
        .padding(.horizontal)
        .padding(.top, 16)
    }
}

// MARK: - Top Tab Enum

enum TopTab: String, CaseIterable {
    case curation = "스크랩한 큐레이션"
    case weadyboard = "스크랩한 웨디보드"
}

// MARK: - TopTabIndicatorView

struct TopTabIndicatorView: View {
    
    @Namespace private var animation
    @Binding var selectedTab: TopTab

    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(TopTab.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation(.easeInOut) {
                        selectedTab = tab
                    }
                }) {
                    VStack(spacing: 14) {
                        Text(tab.rawValue)
                            .fontName(.captionSemibold14)
                            .foregroundStyle(selectedTab == tab ? Color.black100 : Color.gray800)

                        ZStack {
                            if selectedTab == tab {
                                Capsule()
                                    .fill(Color.black100)
                                    .frame(height: 1)
                                    .matchedGeometryEffect(id: "topTab", in: animation)
                            } else {
                                Capsule()
                                    .fill(Color.clear)
                                    .frame(height: 1)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}



//MARK: -큐레이션 스크롤뷰
struct CurationListView: View {
    let items: [CurationItem] // Model 타입 사용
    // 컬럼 구성: 2열 그리드
    var body: some View {
        //스크랩된 큐레이션 없는 경우
        if items.isEmpty {
            NoCurationView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            let columns = [
                GridItem(.flexible(), spacing: 2),
                GridItem(.flexible(), spacing: 2)
            ]

            ScrollView {
                LazyVGrid(columns: columns, spacing: 2) {
                    ForEach(items) { item in
                        Button(action: {
                            // TODO: - 해당 큐레이션 상세 화면으로 이동
                        }) {
                            if item.firstImgUrl.starts(with: "http"), let url = URL(string: item.firstImgUrl) {
                                AsyncImage(url: url) { image in
                                    image.resizable()
                                        .aspectRatio(1, contentMode: .fill)   // ⬅️ 정사각형 타일
                                        .clipped()
                                } placeholder: {
                                    Color.gray.opacity(0.3)
                                        .aspectRatio(1, contentMode: .fill)   // ⬅️ 로딩도 정사각형 유지
                                }
                            } else if !item.firstImgUrl.isEmpty {
                                Image(item.firstImgUrl)
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fill)
                                    .clipped()
                            } else {
                                Color.gray.opacity(0.2)
                                    .aspectRatio(1, contentMode: .fill)
                            }
                            
                        }
                    }
                }
                .padding(.horizontal, 2)
                .padding(.bottom,0)
            }
            .ignoresSafeArea(.all,edges: .bottom)
        }
    }
}

//MARK: -웨디보드 스크롤뷰
struct WeadyboardListView: View {
    let items: [WeadyboardItem] // Model 타입 사용
    // 컬럼 구성: 3열 그리드
    var body: some View {
        if items.isEmpty {
            //스크랩된 웨디보드가 없는 경우
            NoWeadyboardView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            let columns = [
                GridItem(.flexible(), spacing: 2),
                GridItem(.flexible(), spacing: 2),
                GridItem(.flexible(), spacing: 2)
            ]

            ScrollView {
                LazyVGrid(columns: columns, spacing: 2) {
                    ForEach(items) { item in
                        Button(action: {
                            // TODO: - 해당 웨디보드 상세 화면으로 이동
                        }) {
                            // Safe optional handling for imgUrl
                            if let urlStr = item.imgUrl, urlStr.hasPrefix("http"), let url = URL(string: urlStr) {
                                AsyncImage(url: url) { image in
                                    image.resizable()
                                        .aspectRatio(1, contentMode: .fill)
                                        .clipped()
                                } placeholder: {
                                    Color.gray.opacity(0.3)
                                        .aspectRatio(1, contentMode: .fill)
                                }
                            } else if let localName = item.imgUrl, !localName.isEmpty {
                                Image(localName)
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fill)
                                    .clipped()
                            } else {
                                // imgUrl == nil 또는 빈 문자열일 때 플레이스홀더
                                Color.gray.opacity(0.2)
                                    .aspectRatio(1, contentMode: .fill)
                            }
                        }
                    }
                }
                .padding(.horizontal, 2)
                .padding(.bottom,0)
            }
            .ignoresSafeArea(.all,edges: .bottom)
        }
    }
}

// MARK: - SheetView

struct SheetView: View {
    @Binding var showSheet: Bool
    var onDeleteTap: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            Button {
                showSheet = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onDeleteTap()
                }
            } label: {
                Text("스크랩 취소하기")
                    .foregroundStyle(Color(red: 1, green: 0.23, blue: 0.19))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 50)
            }
            Spacer()
        }
    }
}
// MARK: - NoCurationView (스크랩된 큐레이션 없는 경우)
struct NoCurationView: View {
    var body: some View {
        VStack {
            VStack(spacing:20) {
                Text("추천 큐레이션에서 마음에 드는 하루를 담아보세요!")
                    .fontName(.metaMedium12)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Button(action: {
                    // TODO: - 큐레이션 탐색 화면으로 이동
                    //CurationView()
                }) {
                    Text("큐레이션 보러가기")
                        .fontName(.captionSemibold14)
                        .foregroundStyle(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(Color.gray900)
                        .cornerRadius(8)
                }
            }
            .padding(.top, 141)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}


// MARK: - NoWeadyboardView (스크랩된 웨디보드 없는 경우)
struct NoWeadyboardView: View {
    @Environment(NavigationRouter.self) private var router: NavigationRouter?
   
    var body: some View {
        VStack {
            VStack(spacing: 20) {
                Text("웨디보드에서는 다른 사람의 하루도 아카이빙할 수 있어요!")
                    .fontName(.metaMedium12)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Button(action: {
                    router?.push(.weadyboard) // 웨디보드 탐색 화면으로 이동
                }) {
                    Text("웨디보드 보러가기")
                        .fontName(.captionSemibold14)
                        .foregroundStyle(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(Color.gray900)
                        .cornerRadius(8)
                }
            }
            .padding(.top, 141)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}




#Preview {
    WeadychiveView()
}
