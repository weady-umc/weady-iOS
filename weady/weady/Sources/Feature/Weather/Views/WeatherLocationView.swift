//
//  WeatherLocationView.swift
//  weady
//
//  Created by Yoonseo on 7/18/25.
//

import SwiftUI

struct WeatherLocationView: View {
    // MARK: - State & Environment
    @StateObject private var viewModel =  WeatherLocationViewModel()  // 즐겨찾기 목록/서버 통신 관리
    @Environment(\.dismiss) private var dismiss                       // 현재 화면 닫기
    @Environment(\.editMode) private var editMode                     // 편집 모드 토글
    @Environment(HomeRouter.self) var router                          // 화면 전환 라우터
    @State private var selectedPlace: AddressDocument? = nil          // 검색에서 선택된 장소(옵션)

    var body: some View {
        // MARK: - Root Layout
        ZStack(alignment: .top) {
            VStack{
                Spacer().frame(height: 25)
                
                // MARK: - 검색바
                searchBar
                Spacer().frame(height: 25)
                
                // MARK: - 현재 위치 카드 (예시 데이터)
                WeatherLocationCardView(data: WeatherLocationViewModel.example, isCurrentLocation: true, editMode: false)
                Spacer().frame(height: 27)
                
                // MARK: - 즐겨찾기 섹션
                favLocations
            }
            // MARK: - 내비게이션 설정
            .navigationTitle("위치")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .onAppear {
                // 토큰 세팅 및 즐겨찾기 로드
                UserDefaults.standard.set("eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiIyNCIsImVtYWlsIjoieWFuZ3lzMDYzMEBuYXZlci5jb20iLCJwcm92aWRlciI6IktBS0FPIiwiZXhwIjoxNzU1MTgzMDczfQ.FA0WXJieO-2cQsi-I8ig-7PSMfubAmn0gUUfZmjo_CQaspP9bvhhAUTEEzrxHvTGTL7mMf5ZJWYKwSxaDlxgUQ", forKey: "accessToken")
                viewModel.loadFavorites()
            }
            .toolbar {
                // MARK: - 좌측 상단 뒤로가기
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        router.pop()
                    }) {
                        Image("backicon")
                            .foregroundColor(.black)
                    }
                }
            }
            
            // MARK: - 상단 Divider
            Divider()
                .frame(height: 1)
        }
    }
    
    // MARK: - 검색 바 UI (탭 시 검색 화면으로 이동)
    private var searchBar: some View {
        HStack(spacing: 10)
        {
            Spacer(minLength: 10)
            
            Image("searchIcon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 17.5, height: 17.6)
            
            Text("위치, 주소 검색")
                .fontName(.captionRegular14)
                .foregroundStyle(Color.gray200)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(width: 335, height: 40)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.white400)
        )
        .onTapGesture {
            router.push(.weathersearch) // 검색 화면으로 이동
            print("📌 search bar tapped")
        }
    }
    
    // MARK: - 즐겨찾기 목록 섹션
    private var favLocations: some View {
        VStack{
            // MARK: - 헤더(타이틀 + 편집 버튼)
            HStack{
                Text("즐겨찾기")
                Spacer()
                Button(action: {
                    // 편집 모드 토글 (active <-> inactive)
                    editMode?.wrappedValue = (editMode?.wrappedValue == .active) ? .inactive : .active
                }) {
                    if editMode?.wrappedValue == .active {
                        Image("doneIcon")
                            .resizable()
                            .frame(width: 33, height: 20)
                    } else {
                        Image("editIcon")
                            .resizable()
                            .frame(width: 33, height: 20)
                    }
                }
            }
            .frame(width: 335)
            
            Spacer().frame(height: 29)
            
            // MARK: - 비어 있을 때의 안내 뷰
            if viewModel.favoriteLocations.isEmpty {
                VStack(alignment: .center) {
                    Spacer().frame(height: 68.5)
                    Image("addIcon")
                        .resizable()
                        .frame(width: 21.9, height: 21.9)
                    Spacer().frame(height: 11.3)
                    Text("즐겨찾는 위치를 추가해보세요")
                        .fontName(.captionRegular14)
                        .foregroundStyle(Color.black100)
                }
            } else {
                // MARK: - 즐겨찾기 리스트
                List {
                    ForEach(viewModel.favoriteLocations, id: \.id) { (weather: WeatherData) in
                        HStack {
                            // 편집 모드일 때 삭제 버튼 노출
                            if editMode?.wrappedValue == .active {
                                Button(action: {
                                    deleteItem(weather)
                                }) {
                                    Image("deleteicon")
                                        .resizable()
                                        .frame(width: 44, height: 44)
                                        .padding(.leading, 4)
                                }
                                .buttonStyle(.plain)
                            }
                            
                            // 즐겨찾기 카드
                            WeatherLocationCardView(
                                data: weather,
                                isCurrentLocation: false,
                                editMode: editMode?.wrappedValue == .active
                            )
                            .allowsHitTesting(editMode?.wrappedValue != .active) // 편집 중에는 탭 비활성화
                            .contentShape(Rectangle()) // 탭 영역 확장
                            .onTapGesture {
                                router.push(.weatherhome) // 즐겨찾기 탭 시 홈(날씨)로 이동
                            }
                        }
                        .frame(alignment: .leading)
                        .listRowInsets(EdgeInsets())      // 기본 여백 제거
                        .listRowSeparator(.hidden)        // 구분선 숨김
                        .padding(.bottom, 8)
                    }
                }
                .listStyle(.plain)
            }
        }
        // 편집 모드일 때 너비 확장
        .frame(width: editMode?.wrappedValue == .active ? 375 : 335)
    }

    // MARK: - 즐겨찾기 삭제 로직 (낙관적 업데이트)
    func deleteItem(_ weather: WeatherData) {
        guard let favId = weather.favoriteId else { return }
        
        if let idx = viewModel.favoriteLocations.firstIndex(where: { $0.id == weather.id }) {
            let removed = weather
            viewModel.favoriteLocations.remove(at: idx) // 로컬 즉시 제거
            print("🗑️ 로컬에서 즐겨찾기 제거: \(favId)")

            // 서버 삭제 요청
            viewModel.deleteFavoriteFromServer(favoriteId: favId) { ok in
                if ok {
                    print("✅ 즐겨찾기 삭제 성공: \(favId)")
                } else {
                    print("❌ 즐겨찾기 삭제 실패, 복구")
                    // 실패 시 로컬 되돌리기
                    DispatchQueue.main.async {
                        viewModel.favoriteLocations.insert(removed, at: idx)
                    }
                }
            }
        }
    }
}

#Preview {
    // MARK: - 단독 프리뷰 (라우터/네비 환경 주입)
    WeatherLocationView()
        .environment(HomeRouter())
        .environment(NavigationRouter())
}

#Preview {
    // MARK: - Flow Host에서의 프리뷰
    HomeFlowHost() // 여기에 WeatherLocationView를 보여주는 루트
}
