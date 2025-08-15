//
//  WeatherSearchView.swift
//  weady
//
//  Created by Yoonseo on 7/27/25.
//

import SwiftUI

struct WeatherSearchView: View {
    
    @Environment(HomeRouter.self) var router
    @StateObject private var viewModel = WeatherSearchViewModel()
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedPlace: AddressDocument?
    @State private var showWeatherPreview = false
    @State private var previewWeatherData: ShortWeatherData? = nil
    @StateObject private var locationViewModel = WeatherLocationViewModel()
    @StateObject private var addViewModel = WeatherLocationAddViewModel()
    @State private var shouldGoToWeatherLocation = false

    
    var body: some View {
        VStack {
            Spacer().frame(height: 13)
            
            Divider()
                .frame(height: 1)
            
            searchBar
            
            if viewModel.filteredResults.isEmpty {
                Text("🔍 검색 결과가 없습니다.")
            } else {
                searchResultsList
            }

            
            Spacer()
        }
        .navigationTitle("위치")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image("backicon")
                        .foregroundColor(.black)
                }
            }
        }
       


        .onAppear {
            UserDefaults.standard.set("eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiIyNCIsImVtYWlsIjoieWFuZ3lzMDYzMEBuYXZlci5jb20iLCJwcm92aWRlciI6IktBS0FPIiwiZXhwIjoxNzU1MTkyMjMzfQ.0SZnNvaV9kaOSZpVOfmMpPpFCJyt-hlbgO9no5PLQv4el9_BOOV3PL_v_bq8M2TUBuRmykydbQzIZ2v-cj4AIA", forKey: "accessToken")
        }
    }
    
    
    private var searchBar: some View {
        VStack {
            Spacer().frame(height: 14)
            
            HStack(spacing: 10) {
                Spacer(minLength: 10)
                
                Image("searchIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 17.5, height: 17.6)
                
                TextField("", text: $viewModel.searchText, prompt: Text("위치, 주소 검색")
                    .foregroundStyle(Color.gray200)
                )
                .font(AppTextStyle.captionRegular14.font)
                .foregroundStyle(Color.gray200)
                .multilineTextAlignment(.leading)
            }
            .frame(width: 335, height: 40)
            .background(RoundedRectangle(cornerRadius: 5).fill(Color.white400))
        }
        .frame(alignment: .top)
    }

    private var searchResultsList: some View {
        VStack {

            if viewModel.searchResults.isEmpty {
                
                Spacer().frame(height: 40)
                
                Text("🔍 검색 결과가 없습니다.")
                    .foregroundColor(.gray300)
                
                    
                    
            } else {
                List(viewModel.filteredResults, id: \.id) { place in
                    Button(action: {
                        print("✅ 선택된 장소: \(place.address.bCode)")
                        selectedPlace = place
                        viewModel.select(place: place) { weather in
                            if let weather = weather {
                                print("✅ 날씨 데이터 수신 완료: \(weather)")
                                
                                self.previewWeatherData = weather
                                self.showWeatherPreview = true
                                router.push(.weatheradd(place, weather))
                                
                            } else {
                                print("❌ 날씨 데이터를 가져오지 못함")
                            }
                        }
                    }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(place.address.region1depthName) \(place.address.region2depthName) \(place.address.region3depthName)")
                                .font(.body)
                                .foregroundColor(.black)
                            Text("법정동 코드: \(place.address.bCode)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 6)
                    }
                }

                .listStyle(.plain)
                .frame(width: 335)
            }
        }
    }
}

struct WeatherSearchView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherSearchView(selectedPlace: .constant(nil))

            .environment(HomeRouter())

    }
}
