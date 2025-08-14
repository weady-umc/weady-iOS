//
//  WeatherLocationView.swift
//  weady
//
//  Created by Yoonseo on 7/18/25.
//

import SwiftUI

struct WeatherLocationView: View {
    @StateObject private var viewModel =  WeatherLocationViewModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.editMode) private var editMode
    @Environment(HomeRouter.self) var router
    @State private var selectedPlace: AddressDocument? = nil


    
    var body: some View {
        
            ZStack(alignment: .top) {
                
                VStack{
                    
                    Spacer().frame(height: 25)
                    
                    searchBar
                        
                    Spacer().frame(height: 25)
                    
                    WeatherLocationCardView(data: WeatherLocationViewModel.example, isCurrentLocation: true, editMode: false)
                    
                    Spacer().frame(height: 27)
                    
                    favLocations
                    
                }
                .navigationTitle("위치")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .onAppear {
                    UserDefaults.standard.set("eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiIyNCIsImVtYWlsIjoieWFuZ3lzMDYzMEBuYXZlci5jb20iLCJwcm92aWRlciI6IktBS0FPIiwiZXhwIjoxNzU1MTgzMDczfQ.FA0WXJieO-2cQsi-I8ig-7PSMfubAmn0gUUfZmjo_CQaspP9bvhhAUTEEzrxHvTGTL7mMf5ZJWYKwSxaDlxgUQ", forKey: "accessToken")
                
                    viewModel.loadFavorites()
                }

                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            router.pop()
                        }) {
                            Image("backicon")
                                .foregroundColor(.black)
                        }
                        
                    }
                                    }
               
                
                Divider()
                    .frame(height: 1)
                    
            }
        
    }
    
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
            
                .background(RoundedRectangle(cornerRadius: 5)
                    .fill(Color.white400)
                    )
                .onTapGesture {
                    router.push(.weathersearch)
                     print("📌 search bar tapped")
                    }
                    
    }
    
    private var favLocations: some View {
        VStack{
            HStack{
                Text("즐겨찾기")
                
                Spacer()
                
                Button(action: {
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
                List {
                    ForEach(viewModel.favoriteLocations, id: \.id) { (weather: WeatherData) in
                    HStack {
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
                            
                WeatherLocationCardView(
                    data: weather,
                    isCurrentLocation: false,
                    editMode: editMode?.wrappedValue == .active
                )
                .allowsHitTesting(editMode?.wrappedValue != .active)
                .contentShape(Rectangle()) // 클릭 영역 확장
                .onTapGesture {
                    router.push(.weatherhome(weather))
                    
                }

                            
            }
                        .frame(alignment: .leading)
                        .listRowInsets(EdgeInsets()) // 여백 제거
                        .listRowSeparator(.hidden)
                        .padding(.bottom, 8)
                    }
                    
                }
                .listStyle(.plain)
            }

            
            
        }
        .frame(width: editMode?.wrappedValue == .active ? 375 : 335)
        
        

    }


    func deleteItem(_ weather: WeatherData) {
        guard let favId = weather.favoriteId else { return }
        
        if let idx = viewModel.favoriteLocations.firstIndex(where: { $0.id == weather.id }) {
            let removed = weather
            viewModel.favoriteLocations.remove(at: idx)
            print("🗑️ 로컬에서 즐겨찾기 제거: \(favId)")

            viewModel.deleteFavoriteFromServer(favoriteId: favId) { ok in
                if ok {
                    print("✅ 즐겨찾기 삭제 성공: \(favId)")
                } else {
                    print("❌ 즐겨찾기 삭제 실패, 복구")
                    DispatchQueue.main.async {
                        viewModel.favoriteLocations.insert(removed, at: idx)
                    }
                }
            }
        }
    }



}

#Preview {
    WeatherLocationView()
        .environment(HomeRouter())
        .environment(NavigationRouter())
}
#Preview {
    HomeFlowHost() // 여기에 WeatherLocationView를 보여주는 루트
}

