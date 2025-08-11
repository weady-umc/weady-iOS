//
//  WeatherLocationAddView.swift
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
                Color.white.ignoresSafeArea()
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
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            router.pop()
                        }) {
                            Image("backicon")
                                .foregroundColor(.black)
                        }
                        
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                            EditButton()
                        }
                }
                .navigationDestination(for: HomeRoute.self) { route in
                        switch route {
                        case .weathersearch:
                            WeatherSearchView(selectedPlace: $selectedPlace)
                        default:
                            HomeView()
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
                    ForEach(viewModel.favoriteLocations, id: \.id) { weather in
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
                            
                        }
                        .frame(alignment: .leading)
                        .listRowInsets(EdgeInsets()) // 여백 제거
                        .listRowSeparator(.hidden)
                        .padding(.bottom, 8)
                    }
                    .onMove { source, destination in
                        print("Move from \(source) to \(destination)")
                        viewModel.favoriteLocations.move(fromOffsets: source, toOffset: destination)
                        print(viewModel.favoriteLocations.map { $0.location })
                        
                    
                    }

                }
                .listStyle(.plain)
            }

            
            
        }
        .frame(width: editMode?.wrappedValue == .active ? 375 : 335)
        
        

    }
    func deleteItem(_ weather: WeatherData) {
        if let index = viewModel.favoriteLocations.firstIndex(of: weather) {
            viewModel.favoriteLocations.remove(at: index)
        }
    }

}

private struct PreviewHost<Content: View>: View {
    @State private var router = HomeRouter()
    let content: () -> Content
    var body: some View {
        NavigationStack(path: $router.path) {
            content()
        }
        .environment(router)
    }
}

#Preview {
    PreviewHost { WeatherHomeView() }       // WeatherLocationView() 등 교체해서 확인
}


#Preview {
    HomeFlowHost()
}

