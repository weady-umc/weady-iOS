//
//  DetailCurationView.swift
//  weady
//
//  Created by 고석현 on 7/31/25.
//

import SwiftUI

struct DetailCurationView: View {
    @Environment(\.dismiss) private var dismiss
    let cardID: String
    @State private var currentIndex: Int = 0
    private var imageNames: [String] {
        return Array(repeating: cardID == "0" ? "dummycuration1" : "dummycuration2", count: 6)
    }

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 25) {
                DetailCurationImageCarousel(currentIndex: $currentIndex, imageNames: imageNames)
                DetailCurationMapButton()
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 100)
        }
//        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
//        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color.white)
        
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image("backicon")
                        .padding(.top, 50)
                        .padding(10)
                        .frame(width: 44, height: 44, alignment: .center)
                        
                }
            }
            

            ToolbarItem(placement: .principal) {
                VStack(spacing: 0) {
                    Text("선선한 가을 바람에 가기 좋은,")
                        .fontName(.captionMedium14)
                    Text("서초구 노을 맛집 모음")
                        .fontName(.captionMedium14)
                }
                .padding(.top, 50)
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    // TODO: Scrap toggle logic
                }) {
                    Image("scrap")
                        .padding(.top, 50)
                }
            }
        }
    }
}


struct DetailCurationImageCarousel: View {
    @Binding var currentIndex: Int
    let imageNames: [String]

    var body: some View {
        ZStack(alignment: .top) {
            TabView(selection: $currentIndex) {
                ForEach(imageNames.indices, id: \.self) { index in
                    Image(imageNames[index])
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: UIScreen.main.bounds.width, height: 600)
                        .clipped()
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(width: 350, height: 556)
            .cornerRadius(10)
            .ignoresSafeArea(.all, edges: .horizontal)

            IndicatorBarView(currentIndex: currentIndex, count: imageNames.count)
                .padding(.top, 16)
        }
    }
}

struct DetailCurationMapButton: View {
    var body: some View {
        Button(action: {
            // TODO: - 네이버 지도로 연결
        }) {
            Image("goToNaverMap")
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.width - 32, height: 50)
        }
    }
}

struct IndicatorBarView: View {
    let currentIndex: Int
    let count: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<count, id: \.self) { index in
                if index == currentIndex {
                    RoundedRectangle(cornerRadius: 20)
                        .frame(width: 20, height: 6)
                        .foregroundColor(.white)
                } else {
                    Circle()
                        .frame(width: 6, height: 6)
                        .foregroundColor(.white)
                }
            }
        }
    }
}

#Preview {
    DetailCurationView(cardID: "sampleCardID")
}
// This preview is for SwiftUI canvas in Xcode
