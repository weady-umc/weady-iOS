//
//  WeatherLocationAddView.swift
//  weady
//
//  Created by Yoonseo on 7/18/25.
//

import SwiftUI

struct WeatherLocationAddView: View {
    @Bindable private var viewModel: WeatherLocationAddViewModel = .init()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color.white.ignoresSafeArea()
                VStack{
                    
                    Spacer().frame(height: 25)
                    
                    searchBar
                        
                    Spacer().frame(height: 25)
                    
                    WeatherCardView(data: WeatherLocationAddViewModel.example, isCurrentLocation: true)
                    
                    Spacer().frame(height: 27)
                    
                    favLocations
                        
                        
                    
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
                
                Divider()
                    .frame(height: 1)
                    
            }
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
            
            TextField("지금, 날씨가 궁금한 곳은?", text: $viewModel.searchKeyword)
                //.fontName(.captionRegular14)
                .font(AppTextStyle.captionRegular14.font)
                .foregroundStyle(Color.gray200)
                .multilineTextAlignment(TextAlignment.leading)
        }
                .frame(width: 335, height: 40)
            
                .background(RoundedRectangle(cornerRadius: 5)
                    .fill(Color.white400)
                    )
            
            
        
    }
    
    private var favLocations: some View {
        VStack{
            HStack{
                Text("즐겨찾기")
                
                Spacer()
                
                Button(action: {
                    
                }) {
                    Image("fixIcon")
                        .resizable()
                        .frame(width: 33, height: 20)
                }
            }
            .frame(width: 335)
            
            Spacer().frame(height: 29)
            
            if viewModel.favoriteLocations.isEmpty {
                VStack(alignment: .center) {
                    Image("addIcon")
                        .resizable()
                        .frame(width: 21.9, height: 21.9)
                    
                    Text("즐겨찾는 위치를 추가해보세요.")
                        .fontName(.captionRegular14)
                        .foregroundStyle(Color.black100)
                }
                
            } else {
                ForEach(viewModel.favoriteLocations) { weather in WeatherCardView(data:        weather, isCurrentLocation: false)}
            }
        }
        .frame(width: 335)
    }
}

#Preview {
    WeatherLocationAddView()
}
