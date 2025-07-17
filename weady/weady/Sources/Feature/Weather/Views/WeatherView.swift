//
//  WeatherView.swift
//  weady
//
//  Created by Yoonseo on 7/17/25.
//

import SwiftUI

struct WeatherView: View {
    @Bindable var viewModel: WeatherViewModel = .init()
    var body: some View {
        
        
        VStack{
            SegmentView
        }
        
    }
    
    private var SegmentView: some View {
        HStack(spacing: 0) {
            ForEach(WeatherModel.allCases, id: \.id) { segment in sheetSegment(segment: segment)
                
            }
        }
    }
    
    func sheetSegment(segment: WeatherModel) -> some View {
        VStack(spacing: 8) {
            Text(segment.title)
                .foregroundStyle(viewModel.selectedSegment == segment ? Color.gray100 : Color.gray800)
                .fontName(.headingSemibold20)
                .onTapGesture {
                    withAnimation {
                        viewModel.selectedSegment = segment
                    }
                }
            if viewModel.selectedSegment == segment {
                Rectangle()
                    .fill(Color.gray100)
                    .frame(width: 59, height: 2)
                    .presentationCornerRadius(1)
                
            } else {
                Rectangle()
                    .fill(Color.gray800)
                    .frame(width: 59, height: 2)
            }
            }
        }
    }


#Preview {
    WeatherView()
}
