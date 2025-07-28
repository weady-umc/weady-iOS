import Foundation
import SwiftUI

struct UploadWeatherModel {
    var useCurrentLocation: Bool = true
    var usePersonal: Bool = false
    var season: String = ""
    var minTemp: Int = 0
    var maxTemp: Int = 0
    var weatherType: String = ""
}
