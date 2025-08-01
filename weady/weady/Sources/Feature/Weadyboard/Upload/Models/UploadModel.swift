import Foundation
import SwiftUI

struct PostImage: Codable {
    let imgUrl: String
    let imgOrder: Int
}

struct PostPlace: Codable {
    let placeName: String
    let placeAddress: String
}

struct PostRequestBody: Codable {
    let isPublic: Bool
    let content: String
    let imageDtoList: [PostImage]
    let weatherTagId: Int
    let temperatureTagId: Int
    let seasonTagId: Int
    let placeDtoList: [PostPlace]
    let styleIdList: [Int]
}
