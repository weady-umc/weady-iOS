import Foundation
import SwiftUI

struct UploadModel {
    var image: Image
    var weather: UploadWeatherModel
    var fashion: UploadFashionModel
    var location: UploadLocationModel
    var isCommunityPost: Bool = false
    var isAd: Bool = false
}
