//
//  WeatherView.swift
//  weady
//
//  Created by Yoonseo on 7/16/25.
//

import SwiftUI

struct WeatherLocationView: View {
    @Bindable private var viewModel: WeatherLocationViewModel = .init()
    
    var body: some View {
        
        searchBar
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
                .fontName(.captionRegular14)
                .foregroundStyle(Color.gray200)
                .multilineTextAlignment(.leading)
        }
                .frame(width: 335, height: 40)
            
                .background(RoundedRectangle(cornerRadius: 5)
                    .fill(Color.white400)
                    )
            
            
        
    }
}

#Preview {
    WeatherView()
}
