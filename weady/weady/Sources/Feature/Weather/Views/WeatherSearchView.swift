//
//  WeatherSearchView.swift
//  weady
//
//  Created by Yoonseo on 7/27/25.
//

import SwiftUI

struct WeatherSearchView: View {
    
    @StateObject private var viewModel = WeatherSearchViewModel()
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedPlace: KakaoPlace?
    
    var body: some View {
        
        VStack{
            
            Spacer().frame(height: 13)
            
            Divider()
                .frame(height: 1)
            
            searchBar
            
            if !viewModel.filteredResults.isEmpty {
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
        
    }
        

        private var searchBar: some View {
            VStack{
                
                Spacer().frame(height: 14)
                
                HStack(spacing: 10)
                {
                    Spacer(minLength: 10)
                    
                    Image("searchIcon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 17.5, height: 17.6)
                    
                    TextField("", text: $viewModel.searchText, prompt: Text("위치, 주소 검색")
                        .foregroundStyle(Color.gray200)
                        

                    )
                    .onChange(of: viewModel.searchText) {
                        viewModel.search(keyword: viewModel.searchText)
                    } 
                    .font(AppTextStyle.captionRegular14.font)
                    .foregroundStyle(Color.gray200)
                    .multilineTextAlignment(.leading)
                }
                .frame(width: 335, height: 40)
                
                .background(RoundedRectangle(cornerRadius: 5)
                    .fill(Color.white400)
                )
                
            }
            .frame(alignment: .top)
        }
    
   
    private var searchResultsList: some View {
        VStack {
            // 디버깅 로그
            Text("💡 필터링된 검색 결과 수: \(viewModel.filteredResults.count)")

            if viewModel.filteredResults.isEmpty {
                Text("🔍 검색 결과가 없습니다.")
                    .foregroundColor(.gray)
                    .padding(.top, 20)
            } else {
                List(viewModel.filteredResults, id: \.id) { place in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(place.addressName)  // 전체 주소 (동까지)
                            .font(.body)
                            .foregroundColor(.black)

                        if !place.placeName.isEmpty {
                            Text(place.placeName)  // 장소명
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 6)
                    .onTapGesture {
                        print("✅ 선택된 장소: \(place.placeName)")
                        selectedPlace = place
                        viewModel.select(place: place)
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
    }
}

/*NavigationLink(destination: WeatherSearchView(selectedPlace: $selectedPlace)) {
Text("위치 선택하기")
}


*/
