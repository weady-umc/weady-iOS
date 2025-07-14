//
//  WeadychiveView.swift
//  weady
//
//  Created by 고석현 on 7/14/25.
//

import SwiftUI
// 뷰 트리 : WeadychiveView -> TopBar -> TopTabIndicatorView -> CurationListView / WeadyboardListView

//MARK: - Main 웨디카이브 뷰
struct WeadychiveView: View {
    
    @State private var selectedTopTab: TopTab = .curation
    @State private var showSheet = false

    var body: some View {
        VStack(spacing: 0) {
            TopBar(showSheet: $showSheet)
                .padding(.bottom, 12)
            // Top Tab Indicator
            TopTabIndicatorView(selectedTab: $selectedTopTab)
                .padding(.top, 12)
            
            // TODO: - 아래 콘텐츠 분기
            Group {
                switch selectedTopTab {
                case .curation:
                    CurationListView()
                case .weadyboard:
                    WeadyboardListView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .sheet(isPresented: $showSheet) {
            SheetView()
                .presentationDetents([.height(145)])
                .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - TopBar (상단 바)

struct TopBar: View {
    @Binding var showSheet: Bool

    var body: some View {
        HStack {
            // TODO: - Top bar contents (e.g., back button, title, etc.)
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
    var body: some View {
        let columns = [
            GridItem(.flexible(), spacing: 2),
            GridItem(.flexible(), spacing: 2)
        ]
        
        ScrollView {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(0..<10) { index in
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
    var body: some View {
        let columns = [
            GridItem(.flexible(), spacing: 2),
            GridItem(.flexible(), spacing: 2),
            GridItem(.flexible(), spacing: 2)
        ]

        ScrollView {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(0..<30) { index in
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
    var body: some View {
        VStack(alignment: .leading) {
            Text("스크랩 취소하기")
                .foregroundColor(.red)
                .fontName(.bodyMedium16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal,20)
                .padding(.vertical, 50)
            Spacer()
        }
    }
}


#Preview {
    WeadychiveView()
    
}


// MARK: - 삭제 모드 큐레이션 뷰

struct DeleteCurationView: View {
    @Environment(\.dismiss) var dismiss

    @State private var selectedItems: Set<Int> = []

    let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // 상단 바
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                }

                Spacer()

                Text("취소할 항목")
                    .fontName(.headingSemibold20)

                Spacer()

                Button("완료") {
                    // TODO: - 선택된 큐레이션 삭제 처리
                }
                .foregroundColor(.black)
            }
            .padding(.horizontal)
            .padding(.vertical, 16)

            // 큐레이션 그리드
            ScrollView {
                LazyVGrid(columns: columns, spacing: 2) {
                    ForEach(0..<10, id: \.self) { index in
                        ZStack(alignment: .topTrailing) {
                            Image(index % 2 == 0 ? "curation1" : "curation2")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 240)
                                .clipped()
                                .overlay(
                                    selectedItems.contains(index) ?
                                    Color.black.opacity(0.3) : Color.clear
                                )

                            Button(action: {
                                if selectedItems.contains(index) {
                                    selectedItems.remove(index)
                                } else {
                                    selectedItems.insert(index)
                                }
                            }) {
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
    }
}
