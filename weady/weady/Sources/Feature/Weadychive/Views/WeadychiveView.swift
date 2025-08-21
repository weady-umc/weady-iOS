import SwiftUI

// 뷰 트리 : WeadychiveView
//TopBar -> TopTabIndicatorView -> CurationListView / WeadyboardListView
//sheetView -> DeleteView


        
//MARK: - Main 웨디카이브 뷰
struct WeadychiveView: View {
    @StateObject private var viewModel = WeadychiveViewModel()
    @Environment(WeadychiveRouter.self) private var router
    
 
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
            .onChange(of: navigateToDelete, initial: false) { oldValue, newValue in
                guard newValue == false else { return }
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

// MARK: - 탭

enum TopTab: String, CaseIterable {
    case curation = "스크랩한 큐레이션"
    case weadyboard = "스크랩한 웨디보드"
}

// MARK: - 인디케이터뷰

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
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 300)
                                        .clipped()
                                } placeholder: {
                                    Color.gray.opacity(0.3)
                                        .frame(height: 300)
                                }
                            } else if !item.firstImgUrl.isEmpty {
                                Image(item.firstImgUrl)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 300)
                                    .clipped()
                            } else {
                                Color.gray.opacity(0.2)
                                    .frame(height: 300)
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
            GeometryReader { proxy in
                // Layout constants
                let columnsCount = 3
                let spacing: CGFloat = 2
                let sidePadding: CGFloat = 2
                // Compute available content width AFTER horizontal padding
                let available = proxy.size.width - (sidePadding * 2)
                let totalSpacing = spacing * CGFloat(columnsCount - 1)
                let cell = floor((available - totalSpacing) / CGFloat(columnsCount))
                let columns = Array(repeating: GridItem(.fixed(cell), spacing: spacing), count: columnsCount)

                ScrollView {
                    LazyVGrid(columns: columns, spacing: spacing) {
                        ForEach(items) { item in
                            Button(action: {
                                // TODO: - 해당 웨디보드 상세 화면으로 이동
                            }) {
                                ZStack {
                                    // Placeholder to stabilize layout
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.18))

                                    // Remote
                                    if let urlStr = item.imgUrl,
                                       urlStr.hasPrefix("http"),
                                       let url = URL(string: urlStr) {
                                        AsyncImage(url: url) { phase in
                                            switch phase {
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .aspectRatio(1, contentMode: .fill) // fill the square
                                                    .clipped()
                                            case .failure(_):
                                                Image(systemName: "photo")
                                                    .font(.system(size: 22))
                                                    .foregroundStyle(.gray)
                                            case .empty:
                                                ProgressView()
                                            @unknown default:
                                                EmptyView()
                                            }
                                        }
                                    // Local
                                    } else if let localName = item.imgUrl, !localName.isEmpty {
                                        Image(localName)
                                            .resizable()
                                            .aspectRatio(1, contentMode: .fill)
                                            .clipped()
                                    }
                                }
                                .frame(width: cell, height: cell) // hard square
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, sidePadding)
                    .padding(.bottom, 0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
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



#Preview {
    WeadychiveView()
}
