//
//  WeatherSearchView.swift
//  weady
//
//  Created by Yoonseo on 7/27/25.
//

import SwiftUI
import KeychainSwift

struct WeatherSearchView: View {
    
    // MARK: - Environment / ViewModels / State
    @EnvironmentObject var homeRouter: HomeRouter
    @StateObject private var viewModel = WeatherSearchViewModel()      // 검색 텍스트, 검색 결과, 선택 로직 관리
    @Environment(\.dismiss) private var dismiss                         // 현재 화면 닫기
    @Binding var selectedPlace: AddressDocument?                        // 상위로 전달할 선택된 장소
    @State private var showWeatherPreview = false                       // 미리보기 네비게이션 트리거(옵션)
    @State private var previewWeatherData: ShortWeatherData? = nil      // 미리보기용 단기 예보 데이터(옵션)
    @StateObject private var locationViewModel = WeatherLocationViewModel() // 위치 즐겨찾기/상태 관리(옵션)
    @StateObject private var addViewModel = WeatherLocationAddViewModel()   // 변환 뷰모델(옵션)
    @State private var shouldGoToWeatherLocation = false                // 네비게이션 플래그(옵션)
    @State private var didSearch = false

    var body: some View {
        // MARK: - Root Layout
        VStack {

            
            // MARK: - Search Bar
            searchBar
            
            // MARK: - Results Area
            Group {
                if viewModel.isLoading {
                    ProgressView().padding(.top, 40)
                } else if didSearch && viewModel.filteredResults.isEmpty {
                    // 검색했는데 비었을 때만 표시
                    Text("검색 결과가 없습니다.")
                        .foregroundColor(.gray)
                        .padding(.top, 40)
                } else if !viewModel.filteredResults.isEmpty {
                    searchResultsList
                } else {
                    // 초기 상태(검색 전) → 아무 것도 안 보여주거나 안내 문구
                    EmptyView()
                }
            }
            Spacer()
        }
        // MARK: - Navigation Bar
        .edgeSwipeBack(topExclusion: 100) {
            homeRouter.pop()
        }
        .toolbar(.hidden, for: .navigationBar) // 시스템 네비바 숨김
        .safeAreaInset(edge: .top) {
            CustomNavBar(
                viewTitle: "위치",
                showBackButton: true,
                showBottomDivider: true,
                backAction: { homeRouter.pop() }     // 혹은 dismiss() 사용 중이면 { dismiss() }
            )
            .padding(.top, -15)
            .background(Color.white100.ignoresSafeArea(edges: .top))
            
            

        }
        // MARK: - Token Setup
        .onAppear {
            if let t = KeychainSwift().get("serverAccessToken") {
                    UserDefaults.standard.set(t, forKey: "accessToken")
                }

        }
    }
    
    // MARK: - Search Bar View
    private var searchBar: some View {
        VStack {
            Spacer().frame(height: 14)
            
            HStack(spacing: 10) {
                Spacer(minLength: 10)
                
                Image("searchIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 17.5, height: 17.6)
                
                // 실제 입력 필드 (플레이스홀더 스타일 포함)
                TextField("", text: $viewModel.searchText, prompt: Text("위치, 주소 검색")
                    .foregroundStyle(Color.gray200)
                )
                .font(AppTextStyle.captionRegular14.font)
                .foregroundStyle(Color.gray200)
                .multilineTextAlignment(.leading)
                .submitLabel(.search)         // 키보드에 '검색' 표시
                .onSubmit {
                    didSearch = true                 //  검색 시도 플래그
                    viewModel.search(address: viewModel.searchText)    //  즉시 검색
                }

                            // 클리어 버튼
            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.clearAll()         // 텍스트/결과/로딩 모두 초기화
                    didSearch = false            //  '검색 결과 없음' 숨김
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Color.gray300)
            }
            .padding(.trailing, 10)
                }
            }
            .frame(width: 335, height: 40)
            .background(RoundedRectangle(cornerRadius: 5).fill(Color.white400))
        }
        .frame(alignment: .top)
    }

    // MARK: - Search Results List
    private var searchResultsList: some View {
        VStack {
            // 서버 응답이 비어 있을 때의 안내
            if viewModel.searchResults.isEmpty {
                Spacer().frame(height: 40)
                Text("🔍 검색 결과가 없습니다.")
                    .foregroundColor(.clear)
            } else {
                // 필터링된 결과 목록
                List(viewModel.filteredResults, id: \.id) { place in
                    Button(action: {
                        // 선택된 항목 기록
                        print("✅ 선택된 장소: \(place.address.bCode)")
                        selectedPlace = place
                        // 선택 콜백에서 날씨 데이터 요청 → 성공 시 상세 화면으로 이동
                        viewModel.select(place: place) { weather in
                            if let weather = weather {
                                print("✅ 날씨 데이터 수신 완료: \(weather)")
                                self.previewWeatherData = weather
                                self.showWeatherPreview = true
                                homeRouter.push(.weatheradd(place, weather)) // WeatherLocationAddView로 이동
                            } else {
                                print("❌ 날씨 데이터를 가져오지 못함")
                            }
                        }
                    }) {
                        // 한 줄 아이템 UI
                        VStack(alignment: .leading, spacing: 14) {
                            Text("\(place.address.region1depthName) \(place.address.region2depthName) \(place.address.region3depthName)")
                                .fontName(.captionRegular14)
                                .foregroundColor(.black)
                            
                        }
                        .padding(.vertical, 6)
                    }
                    
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.white)
                    
                    
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color.white)
                .frame(width: 335)
            }
        }
    }
}

// MARK: - Preview
struct WeatherSearchView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherSearchView(selectedPlace: .constant(nil))
            .environmentObject(HomeRouter())
    }
}
