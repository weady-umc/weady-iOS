//
//  WeatherHomeView.swift
//  weady
//
//  Created by Yoonseo on 7/18/25.
//

import SwiftUI

struct WeatherHomeView: View {
    @Bindable var viewModel: WeatherHomeViewModel = .init()
   // private let shortData = ShortWeatherData.example
    @Environment(NavigationRouter.self) var router
    @State private var path = NavigationPath()


    
    var body: some View {
        NavigationStack(path: Binding(
            get: { router.path },
            set: { router.path = $0 }
        )) {
            VStack{
                SegmentView
                
                
                if let data = viewModel.shortData {
                                    let addData = viewModel.convertToWeatherAddData(from: data)
                                    weatherView(weather: addData)
                                } else {
                                    ProgressView("날씨를 불러오는 중...")
                                        .onAppear {
                                            UserDefaults.standard.set("eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiIyNCIsImVtYWlsIjoieWFuZ3lzMDYzMEBuYXZlci5jb20iLCJwcm92aWRlciI6IktBS0FPIiwiZXhwIjoxNzU0NjY4OTg4fQ.RaIwox3gZHhagN88NQ4lnN1Iag7r7n_ADHZ1d14gHWMyNd3vgs8N0ZbTX0RXodsmzS2GzdOTF7WWrPfozj7fUg", forKey: "accessToken")
                                            viewModel.fetchShortWeather()
                                        }
                                }
                

            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .weatherlocation:
                    WeatherLocationView()
                default:
                    HomeView()
                }
            }
            
            }
        }

    
    
    private func weatherView(weather: WeatherAddData) -> some View {
        ZStack {
            Image(weather.weatherBackground)
                .resizable()
                .scaledToFit()
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Image("placeIcon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 11.95, height: 17.071)

                    Text(weather.place)
                        .fontName(.bodySemibold16)
                        .foregroundStyle(Color.white100)

                    Button(action: {
                        print("🔵 current router.path before push: \(router.path)")
                        router.push(.weatherlocation)
                        print("🟢 current router.path after push: \(router.path)")
                    }) {
                        Image("downIcon")
                    }

                }

                Spacer().frame(height: 24)

                WeatherMainCardView(weather: weather)

                Spacer().frame(height: 45)

                HourlyWeatherScrollView(hourlyWeatherList: weather.hourlyWeather)
                    .padding(.horizontal, 60)

                Spacer().frame(height: 36)

                rainWind(weather: weather)
            }
        }
    }

    
    private var SegmentView: some View {
        HStack(spacing: 0) {
            ForEach(WeatherModel.allCases, id: \.id) { segment in sheetSegment(segment: segment)
                
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
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
    WeatherHomeView()
        .environment(NavigationRouter())
}

