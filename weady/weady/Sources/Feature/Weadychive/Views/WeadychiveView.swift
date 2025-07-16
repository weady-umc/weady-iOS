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
    
    // MARK: - Properties
    @State private var selectedTopTab: TopTab = .curation // 기본 선택 탭
    @State private var showSheet = false // 시트 표시 여부
    @State private var navigateToDeleteView: Bool = false   // 삭제 뷰로 네비게이션 여부
    @State private var scrappedCurationIDs: [Int] = Array(0..<10) // 임시 더미 데이터: 0부터 9까지의 ID
    @State private var scrappedWeadyboardIDs: [Int] = Array(0..<30) // 임시 더미 데이터: 0부터 29까지의 ID

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
                    CurationListView(ids: scrappedCurationIDs)
                case .weadyboard:
                    WeadyboardListView(ids: scrappedWeadyboardIDs)
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
                           items: $scrappedCurationIDs) { deleted in
                    scrappedCurationIDs.removeAll { deleted.contains($0) }
                }
            } else {
                DeleteView(type: .weadyboard,
                           items: $scrappedWeadyboardIDs) { deleted in
                    scrappedWeadyboardIDs.removeAll { deleted.contains($0) }
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
              .foregroundColor(.clear)
              .frame(width: 0.5, height: 12)
              .background(Color(red: 0.07, green: 0.07, blue: 0.07))
            Text("내가 담은 하루들")
                .fontName(.homeRegular11)
            Spacer()
            Image(systemName: "ellipsis")
                .font(.system(size: 20))
                .foregroundColor(.black100)
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
                            .foregroundColor(selectedTab == tab ? .black100 : .gray800)

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
                        .frame(maxWidth: .infinity) // Capsule spans full width of tab
                    }
                    .frame(maxWidth: .infinity) // Each button takes equal width
                }
            }
        }
    }
}




//MARK: -큐레이션 스크롤뷰
struct CurationListView: View {
    let ids: [Int]
    // 컬럼 구성: 2열 그리드
    var body: some View {
        let columns = [
            GridItem(.flexible(), spacing: 2),
            GridItem(.flexible(), spacing: 2)
        ]

        ScrollView {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(ids, id: \.self) { index in
                    Button(action: {
                        // TODO: - 해당 큐레이션 상세 화면으로 이동
                    }) {
                        Image(index % 2 == 0 ? "curation1" : "curation2")
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

//MARK: -웨디보드 스크롤뷰
struct WeadyboardListView: View {
    let ids: [Int]
    // 컬럼 구성: 3열 그리드
    var body: some View {
        let columns = [
            GridItem(.flexible(), spacing: 2),
            GridItem(.flexible(), spacing: 2),
            GridItem(.flexible(), spacing: 2)
        ]

        ScrollView {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(ids, id: \.self) { index in
                    Button(action: {
                        // TODO: - 해당 웨디보드 상세 화면으로 이동
                    }) {
                        Image("weadyboard\((index % 7) + 1)") // weadyboard1 ~ weadyboard7 순환
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
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 50)
            }
            Spacer()
        }
    }
}


enum DeleteContentType {
    case curation, weadyboard

    var title: String {
        switch self {
        case .curation: return "스크랩한 큐레이션"
        case .weadyboard: return "스크랩한 웨디보드"
        }
    }

    var gridColumns: [GridItem] {
        switch self {
        case .curation: return Array(repeating: GridItem(.flexible(), spacing: 2), count: 2)
        case .weadyboard: return Array(repeating: GridItem(.flexible(), spacing: 2), count: 3)
        }
    }

    func imageName(for index: Int) -> String {
        switch self {
        case .curation: return index % 2 == 0 ? "curation1" : "curation2"
        case .weadyboard: return "weadyboard\((index % 7) + 1)"
        }
    }

    var imageHeight: CGFloat {
        switch self {
        case .curation: return 240
        case .weadyboard: return 164
        }
    }
}

struct DeleteView: View {
    @Environment(\.dismiss) var dismiss
    let type: DeleteContentType
    @Binding var items: [Int]
    var onDelete: ([Int]) -> Void
    @State private var selectedItems: Set<Int> = []

   
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left").foregroundColor(.black)
                }
                Spacer()
                Text("취소할 항목").font(.headline)
                Spacer()
                // 완료 버튼 탭 시: 뷰를 닫고 선택된 항목을 삭제
                Text("완료")
                    .fontName(.captionMedium14)
                    .onTapGesture {
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onDelete(Array(selectedItems))
                        }
                    }
            }
            .padding(.horizontal)
            .padding(.vertical, 16)

            ScrollView {
                LazyVGrid(columns: type.gridColumns, spacing: 2) {
                    // 삭제 가능한 항목 리스트 표시
                    ForEach(items, id: \.self) { index in
                        ZStack(alignment: .topTrailing) {
                            Image(type.imageName(for: index))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: type.imageHeight)
                                .clipped()
                                .overlay(
                                    selectedItems.contains(index) ? Color.black.opacity(0.3) : Color.clear
                                )
                            Button {
                                if selectedItems.contains(index) {
                                    selectedItems.remove(index)
                                } else {
                                    selectedItems.insert(index)
                                }
                            } label: {
                                Image(systemName: selectedItems.contains(index) ? "checkmark.circle.fill" : "circle")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.white)
                                    .background(Color.black.opacity(0.6))
                                    .clipShape(Circle())
                                    .padding(6)
                            }
                        }
                    }
                }
                .padding(.horizontal, 2)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}


#Preview{WeadychiveView()}

