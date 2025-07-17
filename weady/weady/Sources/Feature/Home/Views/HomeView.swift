//
//  HomeView.swift
//  weady
//
//  Created by Yoonseo on 7/13/25.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        
        TopView
        
        Button{
            
        } label: {
            WeatherView
        }
        
        Button{
            
        } label: {
            ClothesView
        }
        
        Button{
            
        } label: {
            PlaceView
        }
        
    }
    
    private var TopView: some View {
        Text("키코님, \n 오늘은 이런 하루 어때요?")
            .foregroundColor(.black100)
            .fontName(.titleSemibold24)
    }
    
    private var WeatherView: some View {
        
        ZStack{
            Image("weatherbackground")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 335.57, height: 147)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack{
                HStack{
                    Text("15º")
                        .foregroundColor(.white100)
                        .fontName(.homeRegular30)
                    
                    VStack{
                        HStack{
                            Image("placeIcon")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 8, height: 11.43)
                            
                            Text("성미산로 성산동")
                                .foregroundColor(.white100)
                                .fontName(.homeMedium11)
                        }
                        
                        Text("최저 10º | 최고 22º")
                            .foregroundColor(.white100)
                            .fontName(.metaRegular10)
                        
                    }
                }
                
                ScrollView(.horizontal, content: {
                    LazyHStack(spacing: 16, content: {
                        
                        //날씨정보
                        
                    })
                })
                .scrollIndicators(.hidden)
                
            }
                
        }
    }
    
    private var ClothesView: some View {
        HStack{
            Image("clothesIcon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 60)
            
            Text("오늘처럼 구름이 많고 쌀쌀한 날엔 \n 얇은 겉옷을 추천드려요.")
                
            
            Image("rightArrow")
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white200)
        )
        .frame(width: 375, height: 50)
    }
    
    private var PlaceView: some View {
        VStack{
            
            HStack{
                
                Text("지금 날씨에 어울리는 장소만 담았어요")
                
                Image("rightArrow")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 10, height: 15.62)
            }
            
            ScrollView(.horizontal, content: {
                LazyHStack(spacing: 16, content: {
                    
                })
            })
            .scrollIndicators(.hidden)
        }
    }
    
}

#Preview {
    HomeView()
}
    