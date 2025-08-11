//
//  HomeModel.swift
//  weady
//
//  Created by Yoonseo on 8/11/25.
//

import Foundation
import Observation

@Observable
final class HomeWeatherStore {
    var lastShort: ShortWeatherData?   // 원본
    var lastAdd: WeatherAddData?       // 변환본(카드에서 바로 씀)
}
