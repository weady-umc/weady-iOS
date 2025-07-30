//
//  WeatherSearchView.swift
//  weady
//
//  Created by Yoonseo on 7/27/25.
//

import SwiftUI

struct WeatherSearchView: View {
    
    @ObservedObject private var viewModel: WeatherSearchViewModel = .init()
    
    var body: some View {
        NavigationStack{
            
            VStack{
                
                Spacer().frame(height: 13)
                
                Divider()
                    .frame(height: 1)
                
                searchBar
                
                
                Spacer()
                    
            }
            .navigationTitle("위치")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        //router 쓰기?
                    }) {
                        Image("backicon")
                            .foregroundColor(.black)
                    }
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
                
                TextField("", text: $viewModel.searchText, prompt: Text("검색을 통해 즐겨찾기를 추가할 수 있어요")
                    .foregroundStyle(Color.gray200)
                )
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
}

#Preview {
    WeatherSearchView()
}
