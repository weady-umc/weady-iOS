//
//  WeadychiveView.swift
//  weady
//
//  Created by 고석현 on 7/14/25.
//

import SwiftUI
// 뷰 트리 : WeadychiveView
//TopBar -> TopTabIndicatorView -> CurationListView / WeadyboardListView
//sheetView -> DeleteView

//MARK: - Main 웨디카이브 뷰
struct WeadychiveView: View {
    @StateObject private var viewModel = WeadychiveViewModel()
    
    // MARK: - 프로퍼티
    @State private var selectedTopTab: TopTab = .curation // 기본 선택 탭
    @State private var showSheet = false // 시트 표시 여부
    @State private var navigateToDeleteView: Bool = false   // 삭제 뷰로 네비게이션 여부


    // MARK: - Body
    var body: some View {
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
        // Sheet 표시: 더보기 탭에서 "스크랩 취소하기"를 눌렀을 때 표시
        .sheet(isPresented: $showSheet) {
            SheetView(showSheet: $showSheet, navigateToDeleteView: $navigateToDeleteView, selectedTopTab: selectedTopTab)
                .presentationDetents([.height(145)])
                .presentationDragIndicator(.visible)
        }
        // 삭제 뷰로 네비게이션: 탭에 따라 해당 삭제 뷰로 이동
        .navigationDestination(isPresented: $navigateToDeleteView) {
            if selectedTopTab == .curation {
                DeleteView(type: .curation,
                           items: .constant(viewModel.scrappedCurationItems.map(\.id))) { deleted in // Model 연동
                    viewModel.deleteCurationItems(with: deleted) // ViewModel 연동
                }
            } else {
                DeleteView(type: .weadyboard,
                           items: .constant(viewModel.scrappedWeadyboardItems.map(\.id))) { deleted in // Model 연동
                    viewModel.deleteWeadyboardItems(with: deleted) // ViewModel 연동
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
                            Image(item.imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 240)
                                .clipped()
                        }
                    }
                }
                .padding(.horizontal, 2)
            }
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
                            Image(item.imageName) // weadyboard 이미지 이름 사용
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 164)
                                .clipped()
                        }
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }
}


// MARK: - SheetView

struct SheetView: View {
    @Binding var showSheet: Bool
    @Binding var navigateToDeleteView: Bool
    var selectedTopTab: TopTab

 
    var body: some View {
        VStack(alignment: .leading) {
            Button {
                showSheet = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    navigateToDeleteView = true
                }
            } label: {
                Text("스크랩 취소하기")
                    .foregroundStyle(Color(red: 1, green: 0.23, blue: 0.19)) //피그마에 맞는 시스템 레드로 바꿈
                //그냥 피그마에 있는 속성 그대로 가져옴. (extension에서 못찾음)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 50)
            }
            Spacer()
        }
    }
}








#Preview{WeadychiveView()}
